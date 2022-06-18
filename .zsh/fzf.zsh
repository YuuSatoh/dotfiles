# ------
# ssh ecs
# ------

function ssh_ecs_cluster() {
    local cluster=$(aws ecs list-clusters | jq -r '.clusterArns[]' | fzf --ansi --reverse)
    if [ -z "${cluster}" ]; then
        return
    fi

    local service=$(aws ecs list-services --cluster $cluster | jq -r '.serviceArns[]' | fzf --ansi --reverse)
    if [ -z "${service}" ]; then
        return
    fi

    local task=$(aws ecs list-tasks --cluster $cluster --service-name $service | jq -r '.taskArns[]' | fzf --ansi --reverse)
    if [ -z "${task}" ]; then
        return
    fi

    ssh_ecs_task $cluster $task
}

function print_ecs_cluster() {
    aws ecs list-clusters | jq -r '.clusterArns[]'
}

function print_ecs_tasks() {
    local cluster=$(aws ecs list-clusters | jq -r '.clusterArns[]' | fzf --ansi --reverse)
    if [ -z "${cluster}" ]; then
        return
    fi

    local service=$(aws ecs list-services --cluster $cluster | jq -r '.serviceArns[]' | fzf --ansi --reverse)
    if [ -z "${service}" ]; then
        return
    fi

    aws ecs list-tasks --cluster $cluster --service-name $service | jq -r '.taskArns[]'
}

function ssh_ecs_task() {
    if [ $# -ne 2 ]; then
        echo 'usage: ssh_ecs_task $cluster $task'
        exit 1
    fi

    local cluster=$1
    local task=$2

    local containerInstance=$(aws ecs describe-tasks --cluster $cluster --tasks $task | jq -r '.tasks[].containerInstanceArn')

    local ec2Id=$(aws ecs describe-container-instances --cluster $cluster --container-instances $containerInstance | jq -r '.containerInstances[].ec2InstanceId')

    local ec2=$(aws ec2 describe-instances --instance-ids $ec2Id --query "Reservations[*].Instances[*].[PublicDnsName, [Tags[?Key=='Name'].Value]]" --output text | tr '\n' ',')
    local addr=$(echo $ec2 | cut -d ',' -f1)
    local env=$(echo $ec2 | cut -d ',' -f2)

    if [ "$(echo $env | grep 'dev')" ]; then
        local pem=$dev_pem
    else
        local pem=$prd_pem
    fi

    ssh -i $pem ec2-user@$addr
}

function fzf-history-selection() {
    BUFFER=$(history 1 | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\*?\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | fzf --query "$LBUFFER")
    CURSOR=${#BUFFER}
    zle reset-prompt
}
zle -N fzf-history-selection
bindkey '^R' fzf-history-selection

function fzf-cd-z() {
    local current_buffer=$BUFFER
    local selected_line="$(z -l $current_buffer | fzf --tac | awk '{ print $2 }' | head -n 1)"

    echo $selected_line
    if [ -n "${selected_line}" ]; then
        BUFFER="cd ${selected_line}"
        zle .accept-line
    fi
}
zle -N fzf-cd-z
bindkey "^j" fzf-cd-z

function fzf-path() {
    local current_buffer=$BUFFER
    local selected_line="$(find . -type d -not -path './node_modules/*' -not -path './.*' | fzf)"

    if [ -n "${selected_line}" ]; then
        BUFFER="$current_buffer${selected_line}"
        CURSOR=${#BUFFER}
    fi
}
zle -N fzf-path
bindkey "^f" fzf-path

function fzf-docker-sh() {
    local selected_line="$(docker ps --format "{{.ID}} {{.Names}} {{.Image}} {{.Command}}" | fzf | awk '{ print $1}')"

    if [ -n "$selected_line" ]; then
        docker exec -it $selected_line sh
    fi
}

function fzf-docker-exec() {
    local selected_line="$(docker ps --format "{{.ID}} {{.Names}} {{.Image}} {{.Command}}" | fzf | awk '{ print $1}')"

    if [ -n "$selected_line" ]; then
        docker exec -it ${selected_line} $1
    fi
}

# docker images list
function fzf-docker-images() {
    local selected_lines="$(docker images --format "{{.ID}} {{.Repository}} {{.Tag}} {{.CreatedSince}} {{.Size}}" | fzf | awk '{ print $1}' | tr '\n' ' ')"

    if [ -n "$selected_lines" ]; then
        echo $selected_lines
    fi
}

# docker containers list
function fzf-docker-ps() {
    local selected_lines="$(docker ps -a --format "{{.ID}} {{.Names}} {{.Image}} {{.Command}}" | fzf | awk '{ print $1}' | tr '\n' ' ')"

    if [ -n "$selected_lines" ]; then
        echo $selected_lines
    fi
}
