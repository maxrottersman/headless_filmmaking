from PIL import Image, ImageDraw, ImageFont
import subprocess
import os

# Get the absolute path of the script's directory
script_dir = os.path.dirname(os.path.abspath(__file__))

# Change the working directory to the script's directory
os.chdir(script_dir)
#print(script_dir)
#exit()

###################
# Define the multiline text
title = "Kim\nGriest"
subtitle2 = "Real Reason \nthe American Middle Class\n is Disappearing"
###################

#### CREATE TITLE IMAGE #####
# Define the size of the image and the multiline text
image_size = (1280, 720)  # Replace with your desired image size
# Create a new transparent image
image = Image.new('RGBA', image_size, (0, 0, 0, 0))
# Load the font
font_path = r"C:/Windows/Fonts/COOPBL.TTF"  # Replace with the path to your font file
font_size = 200  # Replace with your desired font size
font = ImageFont.truetype(font_path, font_size)
# Create a draw object
draw = ImageDraw.Draw(image)
# Calculate the width and height of the text
text_width, text_height = draw.textbbox((0, 0), title, font=font)[2:4]
# Calculate the position of the text to center it in the image
text_position = ((image_size[0] - text_width) // 2, (image_size[1] - text_height) // 2)
# Draw the text onto the image

# SIMPLE TEXT
#draw.multiline_text(text_position, title, font=font, fill="yellow", align='center')

# WITH STROKE!!!
# Draw each line of text centered horizontally with red stroke
stroke_width = 5  # Adjust the width of the stroke as needed
stroke_color = "red"

# Calculate the width and height of a single line of text
single_line_height = draw.textbbox((0, 0), "Sample text", font=font)[3]

# Calculate the total height of the text
line_height = single_line_height * 0.8  # Adjust the line height as needed
total_text_height = len(title.split("\n")) * line_height

# Calculate the starting y position
start_y = (image_size[1] - total_text_height) // 2

# Draw each line of text
for i, line in enumerate(title.split("\n")):
    bbox = draw.textbbox((0, 0), line, font=font)
    text_width = bbox[2] - bbox[0]  # right - left
    text_position_x = (image.width - text_width) // 2  # Center in the entire width

    # Calculate the y position of this line
    text_position_y = start_y + i * line_height  # Use line_height instead of text_height

    # Draw the text with a red stroke
    for offset in range(stroke_width):
        draw.text((text_position_x - offset, text_position_y), line, font=font, fill=stroke_color)
        draw.text((text_position_x + offset, text_position_y), line, font=font, fill=stroke_color)
        draw.text((text_position_x, text_position_y - offset), line, font=font, fill=stroke_color)
        draw.text((text_position_x, text_position_y + offset), line, font=font, fill=stroke_color)

    # Draw the text in the center
    draw.text((text_position_x, text_position_y), line, font=font, fill="yellow")
# Save the image
image.save("title.png")

######### COMPOSITE IMAGE ##########
# Load the background and title images

background = Image.open('storyreview1280x720.png').convert('RGBA')
title = Image.open('title.png').convert('RGBA')

# Define the position where the title image will be pasted onto the background image
title_position = (100, 0)  # Replace with your desired position

# Paste the title onto the background
background.paste(title, title_position, title)

# Save the result
background.save('combined.png')



# # Save the result
# output_path = "thumbnail_title_subtitle.png"
# background.save(output_path)

# Optionally, display the result
#background.show()

# Display the result with a specific program
subprocess.run(['C:\\Program Files\\IrfanView\\i_view64.exe', 'combined.png'])

##

# Draw each line of text centered horizontally with red stroke
# stroke_width = 5  # Adjust the width of the stroke as needed
# stroke_color = "red"

# for line in title.split("\n"):
#     bbox = draw.textbbox((0, 0), line, font=font)
#     text_width = bbox[2] - bbox[0]  # right - left
#     text_height = bbox[3] - bbox[1]  # lower - upper
#     text_position_x = ((background.width - text_width) // 2) + 150  # Center in the left half

#     # Draw the text with a red stroke
#     for offset in range(stroke_width):
#         draw.text((text_position_x - offset, text_position_y), line, font=font, fill=stroke_color)
#         draw.text((text_position_x + offset, text_position_y), line, font=font, fill=stroke_color)
#         draw.text((text_position_x, text_position_y - offset), line, font=font, fill=stroke_color)
#         draw.text((text_position_x, text_position_y + offset), line, font=font, fill=stroke_color)

   