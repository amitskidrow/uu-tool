import random
import time
from datetime import datetime


def main():
    print("🎲 Random Number Generator Started (live reload test)")
    print("=" * 50)

    counter = 1
    while True:
        try:
            # Generate a 3-digit random number (live reload test change)
            random_num = random.randint(1, 5)

            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

            print(f"[{counter:04d}] {timestamp} :: {random_num}")
            counter += 1
            time.sleep(3)

        except KeyboardInterrupt:
            print("\n👋 Generator stopped by user")
            break
        except Exception as e:
            print(f"❌ Error: {e}")
            time.sleep(1)


if __name__ == "__main__":
    main()
