# Define the New Relic pre-built image
FROM public.ecr.aws/newrelic-lambda-layers-for-docker/newrelic-lambda-layers-python:313 AS layer

# Define the base image
FROM public.ecr.aws/lambda/python:3.13

# NewRelic統合用の環境変数
ARG NEW_RELIC_ACCOUNT_ID
ARG NEW_RELIC_LAMBDA_HANDLER=handler.lambda_handler
ARG NEW_RELIC_LICENSE_KEY
ARG NEW_RELIC_TRUSTED_ACCOUNT_KEY
ARG NEW_RELIC_EXTENSION_SEND_FUNCTION_LOGS=true
ARG NEW_RELIC_EXTENSION_LOG_LEVEL=info

ENV NEW_RELIC_ACCOUNT_ID=$NEW_RELIC_ACCOUNT_ID
ENV NEW_RELIC_LAMBDA_HANDLER=$NEW_RELIC_LAMBDA_HANDLER
ENV NEW_RELIC_LICENSE_KEY=$NEW_RELIC_LICENSE_KEY
ENV NEW_RELIC_TRUSTED_ACCOUNT_KEY=$NEW_RELIC_TRUSTED_ACCOUNT_KEY
ENV NEW_RELIC_EXTENSION_SEND_FUNCTION_LOGS=$NEW_RELIC_EXTENSION_SEND_FUNCTION_LOGS
ENV NEW_RELIC_EXTENSION_LOG_LEVEL=$NEW_RELIC_EXTENSION_LOG_LEVEL

# Copy New Relic Layer code
COPY --from=layer /opt/ /opt/

# Copy requirements.txt
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy function code
COPY handler.py ${LAMBDA_TASK_ROOT}

# CMD override to New Relic's handler wrapper
CMD [ "newrelic_lambda_wrapper.handler" ]
