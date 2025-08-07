# Define the New Relic pre-built image
FROM public.ecr.aws/newrelic-lambda-layers-for-docker/newrelic-lambda-layers-python:313 AS layer

# Define the base image
FROM public.ecr.aws/lambda/python:3.13

# Copy New Relic Layer code
COPY --from=layer /opt/ /opt/

# Copy requirements.txt
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install --no-cache-dir -r requirements.txt

# # Copy function code
# COPY handler.py ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
# CMD [ "handler.entrypoint" ]

# CMD override to New Relic's handler wrapper
CMD [ "newrelic_lambda_wrapper.handler" ]
