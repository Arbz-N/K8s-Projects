import time
import os

file_path = "/logs/requests.log"


def tail_log(file_path):
    """
    Continuously tail a log file and print new lines to stdout
    Waits for the file to exist before starting
    """
    # Wait until file exists
    while not os.path.exists(file_path):
        time.sleep(1)

    with open(file_path, "r") as f:
        # Move to end of file
        f.seek(0, os.SEEK_END)

        while True:
            line = f.readline()
            if not line:
                time.sleep(1)
                continue

            print(f"[sidecar] {line}", flush=True)


if __name__ == "__main__":
    tail_log(file_path)