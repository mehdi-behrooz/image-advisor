#!/bin/sh

generate_metric() {
    echo "# HELP $1 $3"
    echo "# TYPE $1 $2"
    metric=$1
    template=$(echo $5 | sed 's/"/\\"/g')
    echo "$6" | jq -r "$4" | while read -r line; do
        set -- $line
        eval "echo $template"
    done
    echo
}

health_status='
    def health_status:
        if test("\\(healthy\\)") then "3"
        elif test("unhealthy") then "-1"
        elif test("health: starting") then "2"
        elif test("Up") then "1"
        else "0"
        end
'

data=$(
    curl --silent --show-error --request GET \
    --unix-socket /var/run/docker.sock \
    "http://localhost/system/df"
)


generate_metric 'iadvisor_image_containers_total' \
                'gauge' \
                'Number of containers built from the image' \
                '.Images[] | [.Id, .RepoTags[0]//"null", .Containers] | @tsv' \
                '$metric{id="$1",tag="$2"} $3' \
                "$data"

generate_metric 'iadvisor_image_size_bytes' \
                'gauge' \
                'The total size of the image including its uniquer and shared layers with other images' \
                '.Images[] | [.Id, .RepoTags[0]//"null", .Size] | @tsv' \
                '$metric{id="$1",tag="$2"} $3' \
                "$data"

generate_metric 'iadvisor_image_shared_size_bytes' \
                'gauge' \
                'The amount of space used by this image that is shared with other images' \
                '.Images[] | [.Id, .RepoTags[0]//"null", .SharedSize] | @tsv' \
                '$metric{id="$1",tag="$2"} $3' \
                "$data"

generate_metric 'iadvisor_image_unique_size_bytes' \
                'gauge' \
                'The amount of space used by this image that is not shared with other images' \
                '.Images[] | [.Id, .RepoTags[0]//"null", (.Size - .SharedSize)] | @tsv' \
                '$metric{id="$1",tag="$2"} $3' \
                "$data"

generate_metric 'iadvisor_images_size_bytes' \
                'gauge' \
                'The total size of all docker images, ignoring the fact that they have shared layers' \
                '[.Images[].Size] | add' \
                '$metric{} $1' \
                "$data"

generate_metric 'iadvisor_layers_size_bytes' \
                'gauge' \
                'The total size of layers on the system' \
                '.LayersSize' \
                '$metric{} $1' \
                "$data"

generate_metric 'iadvisor_volume_size_bytes' \
                'gauge' \
                'The amount of space used by the volume' \
                '.Volumes[] | [.Name, .Driver, .Mountpoint, .UsageData.Size] | @tsv' \
                '$metric{name="$1",driver="$2",mountpoint="$3"} $4' \
                "$data"

generate_metric 'iadvisor_container_healthcheck_state' \
                'gauge' \
                'The healthcheck status of the container: (0=stopped, 1=up, 2=starting-healthcheck, 3=healthy, -1=unhealth)' \
                "$health_status; .Containers[] | [.Id, .Names[0], (.Status | health_status)] | @tsv" \
                '$metric{id="$1",name="$2"} $3' \
                "$data"

