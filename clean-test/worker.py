#!/usr/bin/env python3
import time
import random
import sys

def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 9000
    print(f"Worker service starting on port {port}")
    
    while True:
        num = random.randint(1, 1000)
        print(f"Generated: {num} (port: {port})")
        time.sleep(2)

if __name__ == "__main__":
    main()