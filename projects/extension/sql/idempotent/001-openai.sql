
-------------------------------------------------------------------------------
-- openai_tokenize
-- encode text as tokens for a given model
-- https://github.com/openai/tiktoken/blob/main/README.md
create or replace function ai.openai_tokenize(_model text, _text text) returns int[]
as $python$
    #ADD-PYTHON-LIB-DIR
    import tiktoken
    encoding = tiktoken.encoding_for_model(_model)
    tokens = encoding.encode(_text)
    return tokens
$python$
language plpython3u strict immutable parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_detokenize
-- decode tokens for a given model back into text
-- https://github.com/openai/tiktoken/blob/main/README.md
create or replace function ai.openai_detokenize(_model text, _tokens int[]) returns text
as $python$
    #ADD-PYTHON-LIB-DIR
    import tiktoken
    encoding = tiktoken.encoding_for_model(_model)
    content = encoding.decode(_tokens)
    return content
$python$
language plpython3u strict immutable parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_list_models
-- list models supported on the openai platform
-- https://platform.openai.com/docs/api-reference/models/list
create or replace function ai.openai_list_models(
    _api_key text default null,
    _base_url text default null,
    _extra_headers jsonb default null,
    _extra_query jsonb default null,
    _extra_body jsonb default null
) returns jsonb
as $python$
    #ADD-PYTHON-LIB-DIR
    import ai.openai
    import json
    client = ai.openai.make_client(plpy, _api_key, _base_url)
    # Initialize kwargs
    kwargs = {}
    # Add extra parameters if provided
    if _extra_headers is not None:
        kwargs['extra_headers'] = json.loads(_extra_headers)
    if _extra_query is not None:
        kwargs['extra_query'] = json.loads(_extra_query)
    if _extra_body is not None:
        kwargs['extra_body'] = json.loads(_extra_body)

    request = client.models.list(**kwargs)
    return request.model_dump_json()
$python$
language plpython3u volatile parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_embed
-- generate an embedding from a text value
-- https://platform.openai.com/docs/api-reference/embeddings/create
create or replace function ai.openai_embed
( _input text
, _model text
, _api_key text default null
, _base_url text default null
, _encoding_format text default null
, _dimensions int default null
, _user text default null
, _extra_headers jsonb default null
, _extra_query jsonb default null
, _extra_body jsonb default null
) returns jsonb
as $python$
    #ADD-PYTHON-LIB-DIR
    import ai.openai
    import json
    client = ai.openai.make_client(plpy, _api_key, _base_url)
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
$python$
language plpython3u immutable parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_embed
-- generate embeddings from an array of text values
-- https://platform.openai.com/docs/api-reference/embeddings/create
create or replace function ai.openai_embed
( _input text[]
, _model text
, _api_key text default null
, _base_url text default null
, _encoding_format text default null
, _dimensions int default null
, _user text default null
, _extra_headers jsonb default null
, _extra_query jsonb default null
, _extra_body jsonb default null
) returns jsonb
as $python$
    #ADD-PYTHON-LIB-DIR
    import ai.openai
    import json
    client = ai.openai.make_client(plpy, _api_key, _base_url)
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
$python$
language plpython3u immutable parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_embed
-- generate embeddings from an array of tokens
-- https://platform.openai.com/docs/api-reference/embeddings/create
create or replace function ai.openai_embed
( _model text
, _input int[]
, _api_key text default null
, _base_url text default null
, _encoding_format text default null
, _dimensions int default null
, _user text default null
, _extra_headers jsonb default null
, _extra_query jsonb default null
, _extra_body jsonb default null
) returns jsonb
as $python$
    #ADD-PYTHON-LIB-DIR
    import ai.openai
    import json
    client = ai.openai.make_client(plpy, _api_key, _base_url)
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
$python$
language plpython3u immutable parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_chat_complete
-- text generation / chat completion
-- https://platform.openai.com/docs/api-reference/chat/create
create or replace function ai.openai_chat_complete
( _messages jsonb
, _model text
, _api_key text default null
, _base_url text default null
, _frequency_penalty float8 default null
, _logit_bias jsonb default null
, _logprobs boolean default null
, _top_logprobs int default null
, _max_tokens int default null
, _max_completion_tokens int default null
, _n int default null
, _presence_penalty float8 default null
, _response_format jsonb default null
, _seed int default null
, _stop text default null
, _stream boolean default null
, _temperature float8 default null
, _top_p float8 default null
, _tools jsonb default null
, _tool_choice jsonb default null
, _user text default null
, _metadata jsonb default null
, _service_tier text default null
, _store boolean default null
, _parallel_tool_calls boolean default null
, _extra_headers jsonb default null
, _extra_query jsonb default null
, _extra_body jsonb default null
) returns jsonb
as $python$
    #ADD-PYTHON-LIB-DIR
    import ai.openai
    client = ai.openai.make_client(plpy, _api_key, _base_url)
    import json

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
        "logit_bias": ai.openai.process_json_input(_logit_bias),
        "logprobs": _logprobs,
        "top_logprobs": _top_logprobs,
        "max_completion_tokens": _max_completion_tokens or _max_tokens,
        "n": _n,
        "presence_penalty": _presence_penalty,
        "response_format": ai.openai.process_json_input(_response_format),
        "seed": _seed,
        "stop": _stop,
        "temperature": _temperature,
        "top_p": _top_p,
        "tools": ai.openai.process_json_input(_tools),
        "tool_choice": ai.openai.process_json_input(_tool_choice),
        "user": _user,
        "metadata": ai.openai.process_json_input(_metadata),
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
$python$
language plpython3u volatile parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

------------------------------------------------------------------------------------
-- openai_chat_complete_simple
-- simple chat completion that only requires a message and only returns the response
create or replace function ai.openai_chat_complete_simple
( _message text
, _api_key text default null
) returns text
as $$
declare
    model text := 'gpt-4o';
    messages jsonb;
begin
    messages := pg_catalog.jsonb_build_array(
        pg_catalog.jsonb_build_object('role', 'system', 'content', 'you are a helpful assistant'),
        pg_catalog.jsonb_build_object('role', 'user', 'content', _message)
    );
    return ai.openai_chat_complete(model, messages, _api_key)
        operator(pg_catalog.->)'choices'
        operator(pg_catalog.->)0
        operator(pg_catalog.->)'message'
        operator(pg_catalog.->>)'content';
end;
$$ language plpgsql volatile parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- openai_moderate
-- classify text as potentially harmful or not
-- https://platform.openai.com/docs/api-reference/moderations/create
create or replace function ai.openai_moderate
(   _input text,
    _api_key text default null,
    _base_url text default null,
    _model text default null,
    _extra_headers jsonb default null,
    _extra_query jsonb default null,
    _extra_body jsonb default null
) returns jsonb
as $python$
    #ADD-PYTHON-LIB-DIR
    import ai.openai
    import json
    client = ai.openai.make_client(plpy, _api_key, _base_url)
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
$python$
language plpython3u immutable parallel safe security invoker
set search_path to pg_catalog, pg_temp
;

create or replace function ai.openai_moderate
(   _input text[],
    _api_key text default null,
    _base_url text default null,
    _model text default null,
    _extra_headers jsonb default null,
    _extra_query jsonb default null,
    _extra_body jsonb default null
) returns jsonb
as $python$
    #ADD-PYTHON-LIB-DIR
    import ai.openai
    import json
    client = ai.openai.make_client(plpy, _api_key, _base_url)
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
$python$
language plpython3u immutable parallel safe security invoker
set search_path to pg_catalog, pg_temp
;
