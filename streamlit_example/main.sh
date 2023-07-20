#!/bin/bash

source /etc/profile.d/parallelworks.sh
source /etc/profile.d/parallelworks-env.sh
source /pw/.miniconda3/etc/profile.d/conda.sh
conda activate


f_install_miniconda() {
    install_dir=$1
    echo "Installing Miniconda3-py39_4.9.2"
    conda_repo="https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh"
    ID=$(date +%s)-${RANDOM} # This script may run at the same time!
    nohup wget ${conda_repo} -O /tmp/miniconda-${ID}.sh 2>&1 > /tmp/miniconda_wget-${ID}.out
    rm -rf ${install_dir}
    mkdir -p $(dirname ${install_dir})
    nohup bash /tmp/miniconda-${ID}.sh -b -p ${install_dir} 2>&1 > /tmp/miniconda_sh-${ID}.out
}

f_set_up_conda_from_yaml() {
    CONDA_DIR=$1
    CONDA_ENV=$2
    CONDA_YAML=$3
    CONDA_SH="${CONDA_DIR}/etc/profile.d/conda.sh"
    # conda env export
    # Remove line starting with name, prefix and remove empty lines
    sed -i -e 's/name.*$//' -e 's/prefix.*$//' -e '/^$/d' ${CONDA_YAML}    
    
    if [ ! -d "${CONDA_DIR}" ]; then
        echo "Conda directory <${CONDA_DIR}> not found. Installing conda..."
        f_install_miniconda ${CONDA_DIR}
    fi
    
    echo "Sourcing Conda SH <${CONDA_SH}>"
    source ${CONDA_SH}
    echo "Activating Conda Environment <${CONDA_ENV}>"
    {
        conda activate ${CONDA_ENV}
    } || {
        echo "Conda environment <${CONDA_ENV}> not found. Installing conda environment from YAML file <${CONDA_YAML}>"
        conda env update -n ${CONDA_ENV} -q -f ${CONDA_YAML} #--prune
        {
            echo "Activating Conda Environment <${CONDA_ENV}> again"
            conda activate ${CONDA_ENV}
        } || {
            echo "ERROR: Conda environment <${CONDA_ENV}> not found. Exiting workflow"
            exit 1
        }
    }
}

getOpenPort() {
    minPort=50000
    maxPort=59999

    # Loop until an odd number is found
    while true; do
        openPort=$(curl -s "https://${PARSL_CLIENT_HOST}/api/v2/usercontainer/getSingleOpenPort?minPort=${minPort}&maxPort=${maxPort}&key=${PW_API_KEY}")
        # Check if the number is odd
        if [[ $(($openPort % 2)) -eq 1 ]]; then
            break
        fi
    done
    # Check if openPort variable is a port
    if ! [[ ${openPort} =~ ^[0-9]+$ ]] ; then
        qty=1
        count=0
        for i in $(seq $minPort $maxPort | shuf); do
            out=$(netstat -aln | grep LISTEN | grep $i)
            if [[ "$out" == "" ]] && [[ $(($i % 2)) -eq 1 ]]; then
                    openPort=$(echo $i)
                    (( ++ count ))
            fi
            if [[ "$count" == "$qty" ]];then
                break
            fi
        done
    fi
}

# Makes sure environment is right
f_set_up_conda_from_yaml "/pw/.miniconda3c" "streamlit-alvaro" "streamlit.yaml"
# Gets an available port 
getOpenPort

if [[ "$openPort" == "" ]]; then
    echo "ERROR - cannot find open port..."
    exit 1
fi

source /pw/.miniconda3c/etc/profile.d/conda.sh 
conda activate streamlit-alvaro

# Create kill script:
echo "kill \$(ps -x | grep streamlit | grep ${openPort} | awk '{print \$1}')" > kill.sh

# Create service.html
cp service.html.template service.html
sed -i "s|__PORT__|${openPort}|g"  service.html
# Create service.json
cp service.json.template service.json
sed -i "s|__PORT__|${openPort}|g"  service.json


streamlit run uber_pickups.py \
    --server.enableCORS false \
    --server.enableXsrfProtection false \
    --server.port ${openPort}

# Navigate to
# https://cloud.parallel.works/me/50001/