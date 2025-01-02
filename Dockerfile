FROM python:3.12-slim-bullseye
# Add user docker to the container
RUN useradd -ms /bin/bash docker

# Install dependencies for a python app using requirements.txt
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    tesseract-ocr \
    ffmpeg libsm6 libxext6

# Create the /app directory in /home/docker with owner docker
RUN mkdir -p /home/docker/app && chown -R docker:docker /home/docker/app

# Install dependencies using existing requirements.txt in /home/docker/app/requirements.txt
RUN pip3 install torch torchvision  -f https://download.pytorch.org/whl/torch_stable.html

# Copy requirements.txt to the container
COPY --chown=docker:docker ./requirements.txt /home/docker/app/requirements.txt

RUN pip3 install --no-cache-dir -r /home/docker/app/requirements.txt

# Install node dependencies
RUN apt-get update && apt-get install -y \
    supervisor \
    nodejs npm

# Install all other dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    lsof \
    net-tools

# Copy the rest of the files with docker user as owner
#COPY --chown=docker:docker ./src/frontend/node_modules /home/docker/app/src/frontend/node_modules
COPY --chown=docker:docker ./src/frontend/public /home/docker/app/src/frontend/public
COPY --chown=docker:docker ./src/frontend/src /home/docker/app/src/frontend/src
COPY --chown=docker:docker ./src/frontend/package.json /home/docker/app/src/frontend
COPY --chown=docker:docker ./src/frontend/package-lock.json /home/docker/app/src/frontend
COPY --chown=docker:docker ./src/__init__.py /home/docker/app/src
COPY --chown=docker:docker ./src/extractor.py /home/docker/app/src
COPY --chown=docker:docker .env /home/docker/app
COPY --chown=docker:docker app.py /home/docker/app
COPY --chown=docker:docker requirements.txt /home/docker/app
#COPY --chown=docker:docker . /home/docker/app

# Run npm install
WORKDIR /home/docker/app/src/frontend
RUN npm install

# Give user docker access to the /var/log directory
RUN chown -R docker:docker /var/log

# Switch the working directory
WORKDIR /home/docker/app

# Switch to docker user
USER docker

# Expose port 80
EXPOSE 8080 3000

# Copy the supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Run supervisord
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

## Run the fast api app
#CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
