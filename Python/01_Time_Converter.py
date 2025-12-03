def convert_minutes(minutes):
    hours = minutes // 60          # Full hours
    remaining_minutes = minutes % 60  # Remaining minutes

    # Build readable text
    if hours > 1:
        hour_text = f"{hours} hrs"
    elif hours == 1:
        hour_text = "1 hr"
    else:
        hour_text = ""

    if remaining_minutes > 0:
        minute_text = f"{remaining_minutes} minutes"
    else:
        minute_text = ""

    # Combine result
    if hour_text and minute_text:
        return f"{hour_text} {minute_text}"
    elif hour_text:
        return hour_text
    else:
        return minute_text


# Test examples
print(convert_minutes(130))   # 2 hrs 10 minutes
print(convert_minutes(110))   # 1 hr 50 minutes
print(convert_minutes(45))    # 45 minutes
