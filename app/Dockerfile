FROM python:3.9

WORKDIR /app

COPY app /app
COPY tests /app/tests

RUN pip install --upgrade pip && pip install -r /app/requirements.txt pytest

EXPOSE 5000

# Запускаем приложение
CMD ["python", "/app/app.py"]
