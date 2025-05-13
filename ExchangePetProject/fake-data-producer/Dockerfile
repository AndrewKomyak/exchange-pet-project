FROM python:latest
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY producer.py .
CMD ["python", "producer.py"]