# miniforge image
FROM condaforge/miniforge3

# set up environment (reduce package overhead)
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    SCGEN_HOME=/opt/scgen \
    PATH=/opt/conda/bin:$PATH

# install dependencies
RUN apt-get update &&  apt-get install -y --no-install-recommends build-essential \
    adduser \
    git \
    wget \
        zlib1g-dev && \
    apt-get clean && apt-get purge && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a non-root user
ARG USERNAME=mamba
ARG USERID=1001
RUN adduser --disabled-password --uid $USERID $USERNAME

# workspace
RUN mkdir -p $SCGEN_HOME
WORKDIR $SCGEN_HOME

# (always specify exact version for python packages)
COPY --chown=$USERNAME:$USERNAME . .

# create conda env
RUN conda create -n scgen python=3.12 && conda run -n scgen pip install scgen scanpy scvi pertpy
ENV PATH=/opt/conda/envs/scgen/bin:$PATH

# jupyter notebook
EXPOSE 8888
# if you wnat to run the notebook interactively, please use the following:
# CMD ["jupyter", "notebook", "workdir/scGen_Tutorial_ECCB2025.ipynb", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]  
# or, non-interactively in a terminal, please run:
CMD ["jupyter", "nbconvert", "--to", "notebook", "--execute", "--inplace", "workdir/scGen_Tutorial_ECCB2025.ipynb"]
