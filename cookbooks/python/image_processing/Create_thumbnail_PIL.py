from PIL import Image, ImageDraw, ImageFont

###################
# Define the multiline text
multiline_text = "Max\nRottersman"
###################

# Load the existing image
image_path = "background_interview2.png"  # Replace with the actual path to your image file
background = Image.open(image_path)
draw = ImageDraw.Draw(background)

# Load the Windows Copperplate font
font_path = r"C:/Windows/Fonts/COOPBL.TTF"  # Replace with the actual path to copperpl.ttf
font_size = 160
font = ImageFont.truetype(font_path, font_size)

# Calculate the total height of the multiline text
total_text_height = sum(draw.textsize(line, font=font)[1] for line in multiline_text.split("\n"))

# Calculate the starting position for centering
text_position_y = (background.height - total_text_height) // 2

# Draw each line of text centered horizontally with red stroke
stroke_width = 5  # Adjust the width of the stroke as needed
stroke_color = "red"

for line in multiline_text.split("\n"):
    text_width, text_height = draw.textsize(line, font=font)
    text_position_x = (background.width // 2 - text_width) // 2  # Center in the left half

    # Draw the text with a red stroke
    for offset in range(stroke_width):
        draw.text((text_position_x - offset, text_position_y), line, font=font, fill=stroke_color)
        draw.text((text_position_x + offset, text_position_y), line, font=font, fill=stroke_color)
        draw.text((text_position_x, text_position_y - offset), line, font=font, fill=stroke_color)
        draw.text((text_position_x, text_position_y + offset), line, font=font, fill=stroke_color)

    # Draw the actual text in white
    draw.text((text_position_x, text_position_y), line, font=font, fill="white")
    text_position_y += text_height  # Move to the next line

# Load the "portrait.jpg" image
image_path_portrait = "portrait.jpg"  # Replace with the actual path to portrait.jpg
portrait_image = Image.open(image_path_portrait)

# Calculate the position to center the image on the right
right_image_x = background.width // 2 + (background.width // 2 - portrait_image.width) // 2
right_image_y = (background.height - portrait_image.height) // 2

# Paste the "portrait.jpg" image centered on the right
background.paste(portrait_image, (right_image_x, right_image_y))

# Save the result
output_path = "output_with_stroke.png"
background.save(output_path)

# Optionally, display the result
background.show()
