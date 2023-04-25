#!/usr/bin/env bash

# Remove the following diff from project.godot:
#
# +[editor_plugins]
# +
# +enabled=PoolStringArray( "res://addons/wakatime/plugin.cfg" )
# +

target_plugin="res://addons/wakatime/plugin.cfg"

# Read the input file content from stdin
file_content="$(cat)"

# Check if the [editor_plugins] section and the enabled=PoolStringArray line exist
section_exists=$(echo "$file_content" | ggrep -c '^\[editor_plugins\]')
pool_string_array_exists=$(echo "$file_content" | ggrep -c '^enabled=PoolStringArray')

if [[ $section_exists -gt 0 && $pool_string_array_exists -gt 0 ]]; then
    # Remove the target plugin from the PoolStringArray
    file_content=$(echo "$file_content" | gsed -E "s|(\"$target_plugin\", )||")

    # Remove the target plugin from the PoolStringArray if it's the last item
    file_content=$(echo "$file_content" | gsed -E "s|(, \"$target_plugin\")||")

    # Remove trailing comma and space from the PoolStringArray if the target plugin was the last item
    file_content=$(echo "$file_content" | gsed -E "s|(, )\)|\)|")

    # Remove the entire enabled=PoolStringArray line and associated blank lines if the array is empty
    empty_array_exists=$(echo "$file_content" | ggrep -c '^enabled=PoolStringArray\(\)$')
    if [[ $empty_array_exists -gt 0 ]]; then
        file_content=$(echo "$file_content" | gsed -E '/^\[editor_plugins\]/{N;N;d}')
    fi

    # Remove the entire [editor_plugins] section if the target plugin is the only item in the array
    single_plugin_array_exists=$(echo "$file_content" | ggrep -c "^enabled=PoolStringArray( \"$target_plugin\" )\$")
    if [[ $single_plugin_array_exists -gt 0 ]]; then
        file_content=$(echo "$file_content" | gsed -E '/^\[editor_plugins\]/{N;N;N;d}')
    fi

    # Write the modified content to stdout
    echo "$file_content"
else
    # If the [editor_plugins] section or enabled=PoolStringArray line was not found, just output the original content
    echo "$file_content"
fi
