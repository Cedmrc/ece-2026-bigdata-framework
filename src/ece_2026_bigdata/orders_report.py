import argparse
import os

import duckdb


def orders_report(product=None):
    con = duckdb.connect()

    con.execute("SET TimeZone = 'UTC'")

    bronze = f"s3://{os.environ['LAB_BUCKET_NAME']}/bronze"

    result = con.execute(
        f"""
        SELECT
            strftime(date, '%Y-%m') AS month,
            COUNT(*) AS orders,
            SUM(quantity) AS quantity
        FROM read_csv('{bronze}/orders.csv', strict_mode=false)
        WHERE $product IS NULL OR product = $product
        GROUP BY month
        ORDER BY month
        """,
        {"product": product},
    ).fetchall()

    con.close()
    return result


def main():
    parser = argparse.ArgumentParser(
        prog="orders-report",
        description="Monthly orders report"
    )

    parser.add_argument(
        "-p",
        "--product",
        help="Filter the orders on a product."
    )

    args = parser.parse_args()

    for month, orders, quantity in orders_report(args.product):
        print(f"{month}\t{orders}\t{quantity}")


if __name__ == "__main__":
    main()
