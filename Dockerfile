# This docker image is desired for demo material from the book
# Deep Learning mit TensorFlow, Keras und TensorFlow.js
# https://github.com/deeplearning-mit-tensorflow-keras-tfjs/2020_Zweite_Auflage

# Choose your desired base image
FROM jupyter/minimal-notebook:latest
LABEL author="Veit Droege"

# name your environment and choose python 3.x version
ARG conda_env=python36
ARG py_ver=3.6
ARG py_name="Python 3.6"

# you can add additional libraries you want mamba to install by listing them below the first line and ending with "&& \"
RUN mamba create --quiet --yes -p "${CONDA_DIR}/envs/${conda_env}" python=${py_ver} ipython ipykernel && \
    mamba clean --all -f -y

# alternatively, you can comment out the lines above and uncomment those below
# if you'd prefer to use a YAML file present in the docker build context

# COPY --chown=${NB_UID}:${NB_GID} environment.yml "/home/${NB_USER}/tmp/"
# RUN cd "/home/${NB_USER}/tmp/" && \
#     mamba env create -p "${CONDA_DIR}/envs/${conda_env}" -f environment.yml && \
#     mamba clean --all -f -y

# create Python 3.x environment and link it to jupyter
RUN "${CONDA_DIR}/envs/${conda_env}/bin/python" -m ipykernel install --user --name ${conda_env} --display-name "${py_name}"  && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# any additional pip installs can be added by uncommenting the following line
RUN "${CONDA_DIR}/envs/${conda_env}/bin/pip" install scipy pandas scikit-learn numpy matplotlib plotly
RUN "${CONDA_DIR}/envs/${conda_env}/bin/pip" install tensorflow keras tensorflowjs

# prepend conda environment to path
ENV PATH "${CONDA_DIR}/envs/${conda_env}/bin:${PATH}"

# if you want this environment to be the default one, uncomment the following line:
#ENV CONDA_DEFAULT_ENV ${conda_env}

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

# activate new environment
RUN echo "source activate ${conda_env}" > ~/.bashrc

