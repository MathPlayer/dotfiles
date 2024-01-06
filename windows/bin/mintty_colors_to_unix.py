#!/usr/bin/env python3

content = []
with open(".minttyrc") as f:
    content = f.readlines()

if not content:
    print("No content available")
else:
    for line in content:
        ls = line.strip().split("=")
        if len(ls) != 2:
            continue
        color = ls[0]
        numbers = ls[1].split(",")
        if len(numbers) != 3:
            continue
        newline = "echo -en \"\\e]P*"
        for element in map(int, numbers):
            newline += "{0:X}".format(element)
        newline += "\" #{0}".format(color)
        print(newline)
