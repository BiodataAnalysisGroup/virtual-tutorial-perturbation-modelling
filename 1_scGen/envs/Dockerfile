# miniconda image
FROM continuumio/miniconda3:latest

# user
ARG USERNAME=mamba
ARG USERID=1000
RUN adduser --disabled-password --uid $USERID $USERNAME

# set up environment (reduce package overhead)
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    SCGEN_HOME=/opt/scgen \
    PATH=/opt/conda/envs/scgen/bin:$PATH

# install dependencies
RUN apt-get update &&  apt-get install -y --no-install-recommends build-essential \
	git \
	libgl1-mesa-glx \
	gfortran \
	zlib1g-dev && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# workspace
RUN mkdir -p $SCGEN_HOME && chown -R $USERNAME:$USERNAME $SCGEN_HOME
WORKDIR $SCGEN_HOME

# (always specify exact version for python packages)
COPY --chown=$USERNAME:$USERNAME . .

# create conda env
RUN conda env create -f environment.yml

# python shell
SHELL ["conda", "run", "-n", "scgen", "/bin/bash", "-c"]

# jupyter notebook
EXPOSE 8888
#CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
CMD ["python", "test/test_scgen.py"]
