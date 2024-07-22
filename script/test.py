def exp_neg_x_squared(x):
    ONE = 1e18

    x = int(x * ONE)  # Convert to fixed-point
    term = ONE
    sum = term
    x2 = (x * x) // ONE
    i = 1

    while i < 5:
        term = (term * x2) // ONE
        term = term // i
        if i % 2 != 0:
            term = -term
        sum += term
        i += 1

    return sum / ONE  # Convert back to floating-point

# Example usage
x = 987229310611681261523895814396575744
print(exp_neg_x_squared(x))
