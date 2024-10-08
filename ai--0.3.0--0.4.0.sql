-- Drop command for openai_list_models
drop function if exists @extschema@.openai_list_models(_api_key text);
-- Drop commands for openai_embed
drop function if exists @extschema@.openai_embed(_model text, _input text, _api_key text, _dimensions int, _user text);
drop function if exists @extschema@.openai_embed(_model text, _input text[], _api_key text, _dimensions int, _user text);
drop function if exists @extschema@.openai_embed(_model text, _input int[], _api_key text, _dimensions int, _user text);
-- Drop command for openai_chat_complete
drop function if exists @extschema@.openai_chat_complete(
    _model text, _messages jsonb, _api_key text, _frequency_penalty float8,
    _logit_bias jsonb, _logprobs boolean, _top_logprobs int, _max_tokens int,
    _n int, _presence_penalty float8, _response_format jsonb, _seed int,
    _stop text, _temperature float8, _top_p float8, _tools jsonb,
    _tool_choice jsonb, _user text
    );
-- Drop command for openai_moderate
drop function if exists @extschema@.openai_moderate(_model text, _input text, _api_key text);

-------------------------------------------------------------------------------
-- openai_list_models
-- list models supported on the openai platform
-- https://platform.openai.com/docs/api-reference/models/list
create function @extschema@.openai_list_models(
    _api_key text DEFAULT NULL,
    _base_url text DEFAULT NULL,
    _extra_headers jsonb DEFAULT NULL,
    _extra_query jsonb DEFAULT NULL,
    _extra_body jsonb DEFAULT NULL
    ) returns table (
    id text,
    created timestamptz,
    owned_by text
    )
as $func$
import openai
import json
from datetime import datetime, timezone

def get_setting(setting_name, default=None):
    """Retrieve a setting from Postgres configuration."""
    query = f"SELECT pg_catalog.current_setting('{setting_name}', true) AS value"
    result = plpy.execute(query)
    return result[0]["value"] if result and result[0]["value"] is not None else default

# API Key and Base URL handling
api_key = _api_key or get_setting('ai.openai_api_key')
base_url = _base_url or get_setting('ai.openai_base_url')

# Initialize OpenAI client
client = openai.OpenAI(api_key=api_key, base_url=base_url)
# Initialize kwargs
kwargs = {}
# Add extra parameters if provided
if _extra_headers is not None:
    kwargs['extra_headers'] = json.loads(_extra_headers)
if _extra_query is not None:
    kwargs['extra_query'] = json.loads(_extra_query)
if _extra_body is not None:
    kwargs['extra_body'] = json.loads(_extra_body)

# Make the API call
for model in client.models.list(**kwargs):
    created = datetime.fromtimestamp(model.created, timezone.utc)
    yield (model.id, created, model.owned_by)
$func$
    language plpython3u volatile parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_embed
-- generate an embedding from a text value
-- https://platform.openai.com/docs/api-reference/embeddings/create
create function @extschema@.openai_embed(
    _input text,
    _model text,
    _api_key text DEFAULT NULL,
    _base_url text DEFAULT NULL,
    _encoding_format text DEFAULT NULL,
    _dimensions int DEFAULT NULL,
    _user text DEFAULT NULL,
    _extra_headers jsonb DEFAULT NULL,
    _extra_query jsonb DEFAULT NULL,
    _extra_body jsonb DEFAULT NULL
    ) returns jsonb
as $func$
import openai
import json

def get_setting(setting_name, default=None):
    """Retrieve a setting from Postgres configuration."""
    try:
        query = f"SELECT pg_catalog.current_setting('{setting_name}', true) AS value"
        result = plpy.execute(query)
        return result[0]["value"] if result and result[0]["value"] is not None else default
    except Exception:
        return default

# API Key and Base URL handling
api_key = _api_key or get_setting('ai.openai_api_key')
base_url = _base_url or get_setting('ai.openai_base_url')

# Initialize OpenAI client
client = openai.OpenAI(api_key=api_key, base_url=base_url)

# Prepare kwargs for the API call
kwargs = {
    "input": [_input],
    "model": _model,
}

if _encoding_format is not None:
    kwargs["encoding_format"] = _encoding_format
if _dimensions is not None:
    kwargs["dimensions"] = _dimensions
if _user is not None:
    kwargs["user"] = _user

# Add extra parameters if provided
if _extra_headers is not None:
    kwargs['extra_headers'] = json.loads(_extra_headers)
if _extra_query is not None:
    kwargs['extra_query'] = json.loads(_extra_query)
if _extra_body is not None:
    kwargs['extra_body'] = json.loads(_extra_body)

# Make the API call
response = client.embeddings.create(**kwargs)
return response.model_dump_json()
$func$
    language plpython3u volatile parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_embed
-- generate embeddings from an array of text values
-- https://platform.openai.com/docs/api-reference/embeddings/create
create function @extschema@.openai_embed(
    _input text[],
    _model text,
    _api_key text DEFAULT NULL,
    _base_url text DEFAULT NULL,
    _encoding_format text DEFAULT NULL,
    _dimensions int DEFAULT NULL,
    _user text DEFAULT NULL,
    _extra_headers jsonb DEFAULT NULL,
    _extra_query jsonb DEFAULT NULL,
    _extra_body jsonb DEFAULT NULL
    ) returns jsonb
as $func$
import openai
import json

def get_setting(setting_name, default=None):
    """Retrieve a setting from Postgres configuration."""
    try:
        query = f"SELECT pg_catalog.current_setting('{setting_name}', true) AS value"
        result = plpy.execute(query)
        return result[0]["value"] if result and result[0]["value"] is not None else default
    except Exception:
        return default

# API Key and Base URL handling
api_key = _api_key or get_setting('ai.openai_api_key')
base_url = _base_url or get_setting('ai.openai_base_url')

# Initialize OpenAI client
client = openai.OpenAI(api_key=api_key, base_url=base_url)

# Prepare kwargs for the API call
kwargs = {
    "input": _input,
    "model": _model,
}

if _encoding_format is not None:
    kwargs["encoding_format"] = _encoding_format
if _dimensions is not None:
    kwargs["dimensions"] = _dimensions
if _user is not None:
    kwargs["user"] = _user

# Add extra parameters if provided
if _extra_headers is not None:
    kwargs['extra_headers'] = json.loads(_extra_headers)
if _extra_query is not None:
    kwargs['extra_query'] = json.loads(_extra_query)
if _extra_body is not None:
    kwargs['extra_body'] = json.loads(_extra_body)

# Make the API call
response = client.embeddings.create(**kwargs)
return response.model_dump_json()
$func$
    language plpython3u volatile parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_embed
-- generate embeddings from an array of tokens
-- https://platform.openai.com/docs/api-reference/embeddings/create
create function @extschema@.openai_embed(
    _input int[],
    _model text,
    _api_key text DEFAULT NULL,
    _base_url text DEFAULT NULL,
    _encoding_format text DEFAULT NULL,
    _dimensions int DEFAULT NULL,
    _user text DEFAULT NULL,
    _extra_headers jsonb DEFAULT NULL,
    _extra_query jsonb DEFAULT NULL,
    _extra_body jsonb DEFAULT NULL
    ) returns jsonb
as $func$
import openai
import json

def get_setting(setting_name, default=None):
    """Retrieve a setting from Postgres configuration."""
    try:
        query = f"SELECT pg_catalog.current_setting('{setting_name}', true) AS value"
        result = plpy.execute(query)
        return result[0]["value"] if result and result[0]["value"] is not None else default
    except Exception:
        return default

# API Key and Base URL handling
api_key = _api_key or get_setting('ai.openai_api_key')
base_url = _base_url or get_setting('ai.openai_base_url')

# Initialize OpenAI client
client = openai.OpenAI(api_key=api_key, base_url=base_url)

# Prepare kwargs for the API call
kwargs = {
    "input": [_input],
    "model": _model,
}

if _encoding_format is not None:
    kwargs["encoding_format"] = _encoding_format
if _dimensions is not None:
    kwargs["dimensions"] = _dimensions
if _user is not None:
    kwargs["user"] = _user

# Add extra parameters if provided
if _extra_headers is not None:
    kwargs['extra_headers'] = json.loads(_extra_headers)
if _extra_query is not None:
    kwargs['extra_query'] = json.loads(_extra_query)
if _extra_body is not None:
    kwargs['extra_body'] = json.loads(_extra_body)

# Make the API call
response = client.embeddings.create(**kwargs)
return response.model_dump_json()
$func$
    language plpython3u volatile parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_chat_complete
-- text generation / chat completion
-- https://platform.openai.com/docs/api-reference/chat/create
create function @extschema@.openai_chat_complete(
    _messages jsonb,
    _model text,
    _api_key text DEFAULT NULL,
    _base_url text DEFAULT NULL,
    _frequency_penalty float8 DEFAULT NULL,
    _logit_bias jsonb DEFAULT NULL,
    _logprobs boolean DEFAULT NULL,
    _top_logprobs int DEFAULT NULL,
    _max_tokens int DEFAULT NULL,
    _max_completion_tokens int DEFAULT NULL,
    _n int DEFAULT NULL,
    _presence_penalty float8 DEFAULT NULL,
    _response_format jsonb DEFAULT NULL,
    _seed int DEFAULT NULL,
    _stop text[] DEFAULT NULL,
    _stream boolean DEFAULT NULL,
    _temperature float8 DEFAULT NULL,
    _top_p float8 DEFAULT NULL,
    _tools jsonb DEFAULT NULL,
    _tool_choice jsonb DEFAULT NULL,
    _user text DEFAULT NULL,
    _metadata jsonb DEFAULT NULL,
    _service_tier text DEFAULT NULL,
    _store boolean DEFAULT NULL,
    _parallel_tool_calls boolean DEFAULT NULL,
    _extra_headers jsonb DEFAULT NULL,
    _extra_query jsonb DEFAULT NULL,
    _extra_body jsonb DEFAULT NULL
    ) RETURNS jsonb
AS $func$
import openai
import json

def get_setting(setting_name, default=None):
    """Retrieve a setting from Postgres configuration."""
    query = f"SELECT pg_catalog.current_setting('{setting_name}', true) AS value"
    result = plpy.execute(query)
    return result[0]["value"] if result and result[0]["value"] is not None else default

def process_json_input(input_value):
    """Process JSON input, returning None if input is NULL."""
    return json.loads(input_value) if input_value is not None else None

# The client needs an api_key value passed in even if the endpoint is unsecured, defaulted to 'none'
api_key = _api_key or get_setting('ai.openai_api_key') or 'none'
base_url = _base_url or get_setting('ai.openai_base_url')

# Initialize OpenAI client
client = openai.OpenAI(api_key=api_key, base_url=base_url)

# Process JSON inputs
messages = json.loads(_messages)
if not isinstance(messages, list):
    plpy.error("_messages is not an array")

# Handle _stream parameter since we cannot support it
stream = False if _stream is None else _stream
if _stream:
    plpy.error("Streaming is not supported in this implementation")

# Prepare kwargs for the API call
kwargs = {
    "model": _model,
    "messages": messages,
}

# Add optional parameters only if they are not None
optional_params = {
    "frequency_penalty": _frequency_penalty,
    "logit_bias": process_json_input(_logit_bias),
    "logprobs": _logprobs,
    "top_logprobs": _top_logprobs,
    "max_completion_tokens": _max_completion_tokens or _max_tokens,
    "n": _n,
    "presence_penalty": _presence_penalty,
    "response_format": process_json_input(_response_format),
    "seed": _seed,
    "stop": _stop,
    "temperature": _temperature,
    "top_p": _top_p,
    "tools": process_json_input(_tools),
    "tool_choice": process_json_input(_tool_choice),
    "user": _user,
    "metadata": process_json_input(_metadata),
    "service_tier": _service_tier,
    "store": _store,
    "parallel_tool_calls": _parallel_tool_calls,
}

kwargs.update({k: v for k, v in optional_params.items() if v is not None})

# Add extra parameters if provided
if _extra_headers is not None:
    kwargs['extra_headers'] = json.loads(_extra_headers)
if _extra_query is not None:
    kwargs['extra_query'] = json.loads(_extra_query)
if _extra_body is not None:
    kwargs['extra_body'] = json.loads(_extra_body)

# Make the API call
response = client.chat.completions.create(**kwargs)
return response.model_dump_json()
$func$
    language plpython3u volatile parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_moderate
-- classify text as potentially harmful or not
-- https://platform.openai.com/docs/api-reference/moderations/create
create function @extschema@.openai_moderate(
    _input text,
    _api_key text DEFAULT NULL,
    _base_url text DEFAULT NULL,
    _model text DEFAULT NULL,
    _extra_headers jsonb DEFAULT NULL,
    _extra_query jsonb DEFAULT NULL,
    _extra_body jsonb DEFAULT NULL
    ) RETURNS jsonb
AS $func$
import openai
import json

def get_setting(setting_name, default=None):
    """Retrieve a setting from Postgres configuration."""
    query = f"SELECT pg_catalog.current_setting('{setting_name}', true) AS value"
    result = plpy.execute(query)
    return result[0]["value"] if result and result[0]["value"] is not None else default

# API Key and Base URL handling
api_key = _api_key or get_setting('ai.openai_api_key')
base_url = _base_url or get_setting('ai.openai_base_url')

# Initialize OpenAI client
client = openai.OpenAI(api_key=api_key, base_url=base_url)

# Prepare kwargs for the API call
kwargs = {
    "model": _model,
    "input": _input,
}

# Add extra parameters if provided
if _extra_headers is not None:
    kwargs['extra_headers'] = json.loads(_extra_headers)
if _extra_query is not None:
    kwargs['extra_query'] = json.loads(_extra_query)
if _extra_body is not None:
    kwargs['extra_body'] = json.loads(_extra_body)

# Make the API call
moderation = client.moderations.create(**kwargs)
return moderation.model_dump_json()
$func$
    language plpython3u volatile parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

create function @extschema@.openai_moderate(
    _input text[],
    _api_key text DEFAULT NULL,
    _base_url text DEFAULT NULL,
    _model text DEFAULT NULL,
    _extra_headers jsonb DEFAULT NULL,
    _extra_query jsonb DEFAULT NULL,
    _extra_body jsonb DEFAULT NULL
    ) RETURNS jsonb
AS $func$
import openai
import json

def get_setting(setting_name, default=None):
    """Retrieve a setting from Postgres configuration."""
    query = f"SELECT pg_catalog.current_setting('{setting_name}', true) AS value"
    result = plpy.execute(query)
    return result[0]["value"] if result and result[0]["value"] is not None else default

# API Key and Base URL handling
api_key = _api_key or get_setting('ai.openai_api_key')
base_url = _base_url or get_setting('ai.openai_base_url')

# Initialize OpenAI client
client = openai.OpenAI(api_key=api_key, base_url=base_url)

# Prepare kwargs for the API call
kwargs = {
    "model": _model,
    "input": _input,
}

# Add extra parameters if provided
if _extra_headers is not None:
    kwargs['extra_headers'] = json.loads(_extra_headers)
if _extra_query is not None:
    kwargs['extra_query'] = json.loads(_extra_query)
if _extra_body is not None:
    kwargs['extra_body'] = json.loads(_extra_body)

# Make the API call
moderation = client.moderations.create(**kwargs)
return moderation.model_dump_json()
$func$
    language plpython3u volatile parallel safe security invoker
set search_path to pg_catalog, pg_temp
;