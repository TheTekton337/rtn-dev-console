#!/bin/bash

# Run neofetch for system info display
neofetch --ascii_distro Ubuntu_small --size 80px

sleep 2 # Pause after neofetch

# Modified type_out function to alternate colors
type_out() {
    local text="$1"
    local delay=${2:-0.03} # Default typing speed
    local color_toggle=0 # Toggle for color alternation

    # Define colors
    local color1="\033[36m" # Cyan
    local color2="\033[35m" # Magenta
    local reset_color="\033[0m" # Reset to default

    while IFS= read -r line; do
        if ((color_toggle % 2 == 0)); then
            echo -ne "${color1}" # Apply first color
        else
            echo -ne "${color2}" # Apply second color
        fi
        for ((i=0; i<${#line}; i++)); do
            echo -n "${line:$i:1}"
            sleep $delay
        done
        echo -e "${reset_color}" # Reset color at the end of the line
        ((color_toggle++))
    done <<< "$text"
    sleep 1 # Short pause at the end
}

# Introduction message with color alternation
INTRO_TEXT=$'Mobile applications often face limitations based on the tools available. But what if we could change that?\nToday, we\'re demonstrating rtn-dev-console on iOS - a powerful terminal emulator and SSH client that will be part of a suite of mobile development tools.\n\nLet\'s dive into a live demo showcasing its capabilities...\n'
type_out "$INTRO_TEXT"

# Unicode and Emoji Rendering
UNICODE_TEXT=$'Unicode and Emoji rendering (needs work):\n'
type_out "$UNICODE_TEXT"

echo "🌍 Hello, world! 🌎"

echo "🚀 Rocketing through the space of Unicode: 🛸"

echo "Combining characters: Z͋͂a͂̓l͂͑g̔̓o͐͋"

sleep 2 # A brief pause before moving to the next demo part

# Hyperlinks
HYPERLINK_TEXT=$'\nNow, let\'s test hyperlinks in terminal output. Here\'s a link to learn more about rtn-dev-console:\n\nrtn-dev-console on GitHub: https://github.com/TheTekton337/rtn-dev-console\n'
type_out "$HYPERLINK_TEXT"

sleep 2 # A brief pause

# Color and Image Rendering
COLOR_TEXT=$'Demonstrating ANSI colors, 256-color, and TrueColor support. '
type_out "$COLOR_TEXT"

echo -e "\033[31mRed\033[0m, \033[32mGreen\033[0m, \033[34mBlue\033[0m ANSI color support."

# Displaying ANSI 256 colors and TrueColor directly
# We can explain what we are doing with type_out then show the result with echo -e

# Explain 256 colors
type_out "Now demonstrating 256-color support. Here's an orange..."

# Orange text using ANSI 256-color code
echo -e "\033[38;5;208mOrange (256-color)\033[0m"

# Explain TrueColor
type_out "Next, let's look at TrueColor support. Here's a hot pink..."

# Hot Pink text using TrueColor code
echo -e "\033[38;2;255;105;180mHot Pink (TrueColor)\033[0m\n"

sleep 2 # A brief pause to ensure users are ready for the next part

# Preparing to display images with imgcat
#IMAGE_INTRO_TEXT=$'Displaying images with imgcat for graphics support demo. Please observe the quality of black and white, color, and blur effects on these images.'
#type_out "$IMAGE_INTRO_TEXT"

#sleep 3 # Delay before displaying images to prepare the viewer

# Display images using imgcat
#echo -e "Displaying a black and white image..."
#sleep 2 # Delay to simulate typing
#imgcat black_and_white.jpg
#sleep 5 # Increased delay between images

#echo -e "Next, a colorful image..."
#sleep 2 # Delay to simulate typing
#imgcat color.jpg
#sleep 5 # Increased delay between images

#echo -e "Finally, a blurred image for effect..."
#sleep 2 # Delay to simulate typing
#imgcat blur.jpg
#sleep 5 # Allow some time for the last image

# Encourage users to resize the terminal
#RESIZE_TEXT=$'If you are using SwiftTerm directly, try resizing the terminal window now to see how content reflows and adapts dynamically.'
#type_out "$RESIZE_TEXT"

# Prepare the audience for the SIXEL graphics demo
#SIXEL_INTRO_TEXT=$'Finally, let\'s showcase SIXEL graphics support with a famous GIF. Get ready for Console Cowboy!'
#type_out "$SIXEL_INTRO_TEXT"

#sleep 3 # Give users a moment to anticipate

# Display the Console Cowboys GIF using img2sixel
#echo "Displaying Console Cowboys..."
#sleep 2 # Short pause to simulate typing out the command
#img2sixel console_cowboys.gif

#sleep 5 # Let the GIF display for a while

# Conclusion text after the SIXEL graphics demo
CONCLUSION_TEXT=$'This concludes our demo of rtn-dev-console\'s iOS features. Thank you for watching!'
type_out "$CONCLUSION_TEXT"