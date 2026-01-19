FROM python:3.11

WORKDIR /app

COPY requirement.txt .
RUN pip install --no-cache-dir -r requirement.txt

COPY main_app.py .

EXPOSE 5000

CMD ["python", "main_app.py"]
