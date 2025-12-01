FROM registry.access.redhat.com/ubi8/python-39:latest

USER 0

RUN yum install -y iputils && yum clean all

WORKDIR /opt/app-root/src

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN mkdir -p /opt/app-root/data && \
    chown -R 1001:0 /opt/app-root && \
    chmod -R g+rwX /opt/app-root

USER 1001

ENV FLASK_APP=app.py \
    PYTHONUNBUFFERED=1

EXPOSE 8080

CMD ["python", "app.py"]
