def remove_duplicates(text):
    result = ""  # empty string to store unique characters

    for char in text:
        if char not in result:   # check if character is already added
            result += char       # add only if it's not a duplicate

    return result


# Test examples
print(remove_duplicates("banana"))     
print(remove_duplicates("mississippi"))
print(remove_duplicates("programming"))
