FROM langchain/langgraph-api:3.11



# -- Installing local requirements --
ADD requirements.txt /deps/__outer_control-plane-api-demo/src/requirements.txt
RUN PYTHONDONTWRITEBYTECODE=1 pip install --no-cache-dir -c /api/constraints.txt -r /deps/__outer_control-plane-api-demo/src/requirements.txt
# -- End of local requirements install --

# -- Adding non-package dependency control-plane-api-demo --
ADD . /deps/__outer_control-plane-api-demo/src
RUN set -ex && \
    for line in '[project]' \
                'name = "control-plane-api-demo"' \
                'version = "0.1"' \
                '[tool.setuptools.package-data]' \
                '"*" = ["**/*"]'; do \
        echo "$line" >> /deps/__outer_control-plane-api-demo/pyproject.toml; \
    done
# -- End of non-package dependency control-plane-api-demo --

# -- Installing all local dependencies --
RUN PYTHONDONTWRITEBYTECODE=1 pip install --no-cache-dir -c /api/constraints.txt -e /deps/*
# -- End of local dependencies install --
ENV LANGSERVE_GRAPHS='{"agent": "/deps/__outer_control-plane-api-demo/src/agent.py:graph"}'



# -- Ensure user deps didn't inadvertently overwrite langgraph-api
RUN mkdir -p /api/langgraph_api /api/langgraph_runtime /api/langgraph_license &&     touch /api/langgraph_api/__init__.py /api/langgraph_runtime/__init__.py /api/langgraph_license/__init__.py
RUN PYTHONDONTWRITEBYTECODE=1 pip install --no-cache-dir --no-deps -e /api
# -- End of ensuring user deps didn't inadvertently overwrite langgraph-api --
# -- Removing pip from the final image ~<:===~~~ --
RUN pip uninstall -y pip setuptools wheel &&     rm -rf /usr/local/lib/python*/site-packages/pip* /usr/local/lib/python*/site-packages/setuptools* /usr/local/lib/python*/site-packages/wheel* &&     find /usr/local/bin -name "pip*" -delete
# -- End of pip removal --

WORKDIR /deps/__outer_control-plane-api-demo/src