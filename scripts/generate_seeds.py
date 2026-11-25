"""Generate the synthetic seed CSVs for the dbt project.

All data is invented: fake customer names, fake product catalog, random
orders. Nothing here comes from any real system. Re-running with the same
seed produces the same files.
"""

import csv
import random
from datetime import date, timedelta
from pathlib import Path

SEED = 20261124
OUT = Path(__file__).resolve().parent.parent / "seeds"

FIRST = [
    "Ava", "Liam", "Maya", "Noah", "Zoe", "Ethan", "Ruby", "Lucas",
    "Ivy", "Owen", "Nora", "Eli", "Lena", "Milo", "Sara", "Adam",
    "Tara", "Victor", "Priya", "Jonas", "Elena", "Marcus", "Dana",
    "Felix", "Amara", "Hugo", "Ines", "Omar", "Clara", "Dev",
]
LAST = [
    "Anderson", "Baker", "Chen", "Davis", "Evans", "Foster", "Garcia",
    "Hughes", "Ingram", "Johnson", "Kim", "Lopez", "Martin", "Nguyen",
    "Owens", "Patel", "Quinn", "Rivera", "Smith", "Taylor", "Umar",
    "Vargas", "Wright", "Xu", "Young", "Zhang", "Ali", "Novak",
]
REGIONS = ["North", "South", "East", "West", "Central"]
SEGMENTS = ["consumer", "small_business", "enterprise"]
CHANNELS = ["web", "mobile", "phone"]
STATUSES = ["completed", "completed", "completed", "shipped", "cancelled", "refunded"]

PRODUCTS = [
    ("Wireless Headphones", "Electronics", "Audio", 3499, 7999),
    ("Mechanical Keyboard", "Electronics", "Accessories", 4200, 8999),
    ("4K Monitor 27in", "Electronics", "Displays", 18900, 32900),
    ("Laptop Stand", "Electronics", "Accessories", 1800, 3999),
    ("USB-C Hub", "Electronics", "Accessories", 1200, 2999),
    ("Noise-Cancelling Earbuds", "Electronics", "Audio", 5900, 12900),
    ("Smart Speaker", "Electronics", "Audio", 2400, 4999),
    ("Webcam HD", "Electronics", "Accessories", 2100, 5499),
    ("Ergonomic Chair", "Furniture", "Seating", 14500, 29900),
    ("Standing Desk", "Furniture", "Desks", 19900, 44900),
    ("Desk Lamp", "Furniture", "Lighting", 1500, 3499),
    ("Bookshelf", "Furniture", "Storage", 6800, 12900),
    ("Office Chair Mat", "Furniture", "Accessories", 900, 2499),
    ("Filing Cabinet", "Furniture", "Storage", 5200, 11900),
    ("Running Shoes", "Apparel", "Footwear", 3800, 8999),
    ("Rain Jacket", "Apparel", "Outerwear", 2900, 7499),
    ("Cotton T-Shirt", "Apparel", "Tops", 600, 1999),
    ("Denim Jeans", "Apparel", "Bottoms", 1400, 4999),
    ("Wool Sweater", "Apparel", "Tops", 1800, 5999),
    ("Baseball Cap", "Apparel", "Accessories", 400, 1499),
    ("Yoga Mat", "Fitness", "Equipment", 1100, 2999),
    ("Dumbbell Set 20lb", "Fitness", "Equipment", 4500, 9999),
    ("Resistance Bands", "Fitness", "Equipment", 700, 1999),
    ("Water Bottle 1L", "Fitness", "Accessories", 500, 1499),
    ("Blender", "Home", "Kitchen", 2800, 6999),
    ("Coffee Maker", "Home", "Kitchen", 3400, 8999),
    ("Air Fryer", "Home", "Kitchen", 4100, 9999),
    ("Cookware Set", "Home", "Kitchen", 6900, 15900),
    ("Vacuum Cleaner", "Home", "Cleaning", 8900, 19900),
    ("LED Bulb Pack", "Home", "Lighting", 600, 1799),
    ("Board Game", "Toys", "Games", 1200, 3499),
    ("Puzzle 1000pc", "Toys", "Games", 500, 1499),
    ("Building Blocks Set", "Toys", "Construction", 1600, 4999),
    ("Remote Control Car", "Toys", "Vehicles", 2200, 5999),
    ("Notebook A5", "Office", "Stationery", 200, 799),
    ("Pen Set", "Office", "Stationery", 300, 999),
    ("Desk Organizer", "Office", "Storage", 800, 2499),
    ("Backpack", "Office", "Bags", 1900, 5499),
    ("Laptop Sleeve", "Office", "Bags", 900, 2999),
    ("Wireless Mouse", "Electronics", "Accessories", 900, 2499),
]


def main() -> None:
    rng = random.Random(SEED)
    OUT.mkdir(parents=True, exist_ok=True)

    customers = []
    start = date(2023, 1, 1)
    for i in range(1, 201):
        first, last = rng.choice(FIRST), rng.choice(LAST)
        signup = start + timedelta(days=rng.randrange(0, 700))
        updated = signup + timedelta(days=rng.randrange(0, 300))
        customers.append({
            "customer_id": i,
            "first_name": first,
            "last_name": last,
            "email": f"{first.lower()}.{last.lower()}{i}@example.com",
            "signup_date": signup.isoformat(),
            "region": rng.choice(REGIONS),
            "segment": rng.choice(SEGMENTS),
            "is_active": str(rng.random() > 0.08).lower(),
            "updated_at": updated.isoformat(),
        })

    products = []
    for i, (name, cat, sub, cost, price) in enumerate(PRODUCTS, start=1):
        products.append({
            "product_id": i,
            "product_name": name,
            "category": cat,
            "subcategory": sub,
            "unit_cost_cents": cost,
            "unit_price_cents": price,
            "is_active": "true",
        })

    orders = []
    items = []
    item_id = 1
    order_start = date(2024, 1, 1)
    for oid in range(1, 801):
        cust = rng.choice(customers)
        order_date = order_start + timedelta(days=rng.randrange(0, 690))
        status = rng.choice(STATUSES)
        discount = rng.choice([0, 0, 0, 500, 1000, 2500])
        orders.append({
            "order_id": oid,
            "customer_id": cust["customer_id"],
            "order_date": order_date.isoformat(),
            "status": status,
            "channel": rng.choice(CHANNELS),
            "discount_cents": discount,
        })
        for _ in range(rng.randrange(1, 5)):
            prod = rng.choice(products)
            items.append({
                "order_item_id": item_id,
                "order_id": oid,
                "product_id": prod["product_id"],
                "quantity": rng.randrange(1, 4),
                "unit_price_cents": prod["unit_price_cents"],
            })
            item_id += 1

    for name, rows in [
        ("raw_customers.csv", customers),
        ("raw_products.csv", products),
        ("raw_orders.csv", orders),
        ("raw_order_items.csv", items),
    ]:
        with open(OUT / name, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
            writer.writeheader()
            writer.writerows(rows)
        print(f"{name}: {len(rows)} rows")


if __name__ == "__main__":
    main()
