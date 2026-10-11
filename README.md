
# Dataset generator

This project generates random datasets consisting of users and orders.

The scripts are written in Python and the project uses [uv](https://docs.astral.sh/uv/) to manage dependencies.

## Usage

Display the users generator help:

```bash
uv run dataset-users -h
```

Display the orders generator help:

```bash
uv run dataset-orders -h
```

Generate 10 users in CSV format:

```bash
uv run dataset-users -c 10 -o csv
```

Generate orders for 10 users in JSON Lines format:

```bash
uv run dataset-orders -u 10 -C 1 -c 3 -o jsonline
```
