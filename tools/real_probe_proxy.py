import csv
import socket
import struct
import threading
import time
from pathlib import Path

ROOT = Path.cwd() / "probe-output"
ROOT.mkdir(parents=True, exist_ok=True)
RUN_ID = time.strftime("%Y%m%d-%H%M%S")
EVENTS = ROOT / f"events-{RUN_ID}.csv"
SUMMARY = ROOT / f"summary-{RUN_ID}.txt"

LISTEN_BAB = ("127.0.0.1", 18888)
FWD_VRCFT = ("127.0.0.1", 8888)
LISTEN_VRCHAT = ("127.0.0.1", 9000)

latest_frame_ready = {"seq": None, "t": None}
latest_bab_packet = {"seq": 0, "t": None}
latencies_frame_ready_ms = []
latencies_bab_packet_ms = []
counts = {"bab_packets": 0, "frame_ready": 0, "vrcft_packets": 0}
lock = threading.Lock()
stop = threading.Event()


def osc_string(data, offset):
    end = data.find(b"\0", offset)
    if end < 0:
        return "", len(data)
    value = data[offset:end].decode("utf-8", errors="replace")
    return value, (end + 4) & ~3


def parse_osc(data):
    addr, offset = osc_string(data, 0)
    typetag, offset = osc_string(data, offset)
    values = []
    for tag in typetag[1:] if typetag.startswith(",") else "":
        if tag == "i" and offset + 4 <= len(data):
            values.append(struct.unpack(">i", data[offset:offset + 4])[0])
            offset += 4
        elif tag == "f" and offset + 4 <= len(data):
            values.append(struct.unpack(">f", data[offset:offset + 4])[0])
            offset += 4
        elif tag == "s":
            value, offset = osc_string(data, offset)
            values.append(value)
        else:
            break
    return addr, values


def percentile(values, p):
    if not values:
        return 0.0
    sorted_values = sorted(values)
    idx = min(len(sorted_values) - 1, max(0, int(round((len(sorted_values) - 1) * p))))
    return sorted_values[idx]


def write_event(writer, kind, address, values, delta_frame_ms="", delta_bab_ms=""):
    writer.writerow({
        "perf_counter": f"{time.perf_counter():.9f}",
        "epoch": f"{time.time():.9f}",
        "kind": kind,
        "address": address,
        "values": "|".join(str(value) for value in values),
        "frame_seq": latest_frame_ready["seq"] if latest_frame_ready["seq"] is not None else "",
        "bab_packet_seq": latest_bab_packet["seq"],
        "delta_from_frame_ready_ms": delta_frame_ms,
        "delta_from_last_bab_packet_ms": delta_bab_ms,
    })


def bab_listener(writer, csv_file):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(LISTEN_BAB)
    sock.settimeout(0.25)
    while not stop.is_set():
        try:
            data, _ = sock.recvfrom(65535)
        except socket.timeout:
            continue
        now = time.perf_counter()
        try:
            addr, values = parse_osc(data)
        except Exception:
            addr, values = "<parse-error>", []
        with lock:
            counts["bab_packets"] += 1
            latest_bab_packet["seq"] = counts["bab_packets"]
            latest_bab_packet["t"] = now
            if addr == "/vrcft/babble/frameReady":
                counts["frame_ready"] += 1
                latest_frame_ready["seq"] = values[0] if values else counts["frame_ready"]
                latest_frame_ready["t"] = now
            write_event(writer, "bab_to_vrcft", addr, values)
            csv_file.flush()
        sock.sendto(data, FWD_VRCFT)
    sock.close()


def vrcft_output_listener(writer, csv_file):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(LISTEN_VRCHAT)
    sock.settimeout(0.25)
    while not stop.is_set():
        try:
            data, _ = sock.recvfrom(65535)
        except socket.timeout:
            continue
        now = time.perf_counter()
        try:
            addr, values = parse_osc(data)
        except Exception:
            addr, values = "<parse-error>", []
        delta_frame = ""
        delta_bab = ""
        with lock:
            counts["vrcft_packets"] += 1
            if latest_frame_ready["t"] is not None:
                delta_value = (now - latest_frame_ready["t"]) * 1000.0
                if 0 <= delta_value < 1000:
                    latencies_frame_ready_ms.append(delta_value)
                    delta_frame = f"{delta_value:.6f}"
            if latest_bab_packet["t"] is not None:
                delta_value = (now - latest_bab_packet["t"]) * 1000.0
                if 0 <= delta_value < 1000:
                    latencies_bab_packet_ms.append(delta_value)
                    delta_bab = f"{delta_value:.6f}"
            write_event(writer, "vrcft_to_vrchat", addr, values, delta_frame, delta_bab)
            csv_file.flush()
    sock.close()


def main():
    with EVENTS.open("w", newline="", encoding="utf-8") as csv_file:
        fieldnames = [
            "perf_counter",
            "epoch",
            "kind",
            "address",
            "values",
            "frame_seq",
            "bab_packet_seq",
            "delta_from_frame_ready_ms",
            "delta_from_last_bab_packet_ms",
        ]
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        t1 = threading.Thread(target=bab_listener, args=(writer, csv_file), daemon=True)
        t2 = threading.Thread(target=vrcft_output_listener, args=(writer, csv_file), daemon=True)
        t1.start()
        t2.start()
        print(f"RUN_ID={RUN_ID}", flush=True)
        print(f"EVENTS={EVENTS}", flush=True)
        print("READY", flush=True)
        try:
            while not stop.is_set():
                time.sleep(0.25)
        except KeyboardInterrupt:
            stop.set()
        t1.join(timeout=1)
        t2.join(timeout=1)
    vals = list(latencies_frame_ready_ms)
    bab_vals = list(latencies_bab_packet_ms)
    with SUMMARY.open("w", encoding="utf-8") as f:
        f.write(f"run_id={RUN_ID}\n")
        f.write(f"events={EVENTS}\n")
        for key, value in counts.items():
            f.write(f"{key}={value}\n")
        f.write(f"frame_ready_samples={len(vals)}\n")
        if vals:
            f.write(f"frame_ready_mean_ms={sum(vals) / len(vals):.6f}\n")
            f.write(f"frame_ready_median_ms={percentile(vals, 0.50):.6f}\n")
            f.write(f"frame_ready_p90_ms={percentile(vals, 0.90):.6f}\n")
            f.write(f"frame_ready_p95_ms={percentile(vals, 0.95):.6f}\n")
            f.write(f"frame_ready_max_ms={max(vals):.6f}\n")
        f.write(f"last_bab_packet_samples={len(bab_vals)}\n")
        if bab_vals:
            f.write(f"last_bab_packet_mean_ms={sum(bab_vals) / len(bab_vals):.6f}\n")
            f.write(f"last_bab_packet_median_ms={percentile(bab_vals, 0.50):.6f}\n")
            f.write(f"last_bab_packet_p90_ms={percentile(bab_vals, 0.90):.6f}\n")
            f.write(f"last_bab_packet_p95_ms={percentile(bab_vals, 0.95):.6f}\n")
            f.write(f"last_bab_packet_max_ms={max(bab_vals):.6f}\n")
    print(f"SUMMARY={SUMMARY}", flush=True)


if __name__ == "__main__":
    main()

