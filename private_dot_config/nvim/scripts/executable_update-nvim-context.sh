#!/bin/bash

# Update Neovim context bridge file
# This script is called by starship hooks to share context with nvim

BRIDGE_FILE="/tmp/nvim-context.json"

# Get thermal state (macOS specific)
get_thermal_state() {
    # pmset -g thermlog can hang, so use a simpler approach
    # Check if system has been throttled recently
    local throttled=$(pmset -g therm 2>/dev/null | grep -c "CPU_Speed_Limit")
    if [ "$throttled" -gt 0 ]; then
        echo "85"  # Assume high temp if throttled
    else
        echo "45"  # Normal operating temp
    fi
}

# Get memory usage percentage
get_memory_usage() {
    if command -v vm_stat >/dev/null 2>&1; then
        # macOS
        local pages_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        local pages_active=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
        local pages_inactive=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
        local pages_speculative=$(vm_stat | grep "Pages speculative" | awk '{print $3}' | sed 's/\.//')
        local pages_wired=$(vm_stat | grep "Pages wired" | awk '{print $4}' | sed 's/\.//')
        
        local total=$((pages_free + pages_active + pages_inactive + pages_speculative + pages_wired))
        local used=$((pages_active + pages_wired))
        
        if [ $total -gt 0 ]; then
            echo $(( (used * 100) / total ))
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# Get current GTD task (placeholder - would integrate with actual GTD system)
get_gtd_task() {
    # Check if there's a GTD task file or environment variable
    if [ -n "$GTD_CURRENT_TASK" ]; then
        echo "$GTD_CURRENT_TASK"
    elif [ -f "$HOME/.gtd/current_task" ]; then
        cat "$HOME/.gtd/current_task" | head -1
    else
        echo ""
    fi
}

# Get performance cores usage (M3 Pro specific)
get_performance_cores() {
    if system_profiler SPHardwareDataType 2>/dev/null | grep -q "Apple M3 Pro"; then
        # Check if we're using performance cores
        local cpu_usage=$(ps aux | awk '{sum+=$3} END {print int(sum)}')
        echo "$cpu_usage"
    else
        echo "0"
    fi
}

# Main update function
update_context() {
    local thermal=$(get_thermal_state)
    local memory=$(get_memory_usage)
    local gtd_task=$(get_gtd_task)
    local perf_cores=$(get_performance_cores)
    local timestamp=$(date +%s)
    
    # Create JSON object
    cat > "$BRIDGE_FILE" <<EOF
{
  "thermal_state": $thermal,
  "memory_usage": $memory,
  "gtd_task": "$gtd_task",
  "performance_cores": $perf_cores,
  "timestamp": $timestamp,
  "claude_session": "$CLAUDE_SESSION",
  "ai_models": {
    "anthropic": $([ -n "$ANTHROPIC_API_KEY" ] && echo "true" || echo "false"),
    "openai": $([ -n "$OPENAI_API_KEY" ] && echo "true" || echo "false"),
    "groq": $([ -n "$GROQ_API_KEY" ] && echo "true" || echo "false")
  }
}
EOF
}

# Run update
update_context