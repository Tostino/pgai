import json
import openai
from typing import Optional


def get_openai_api_key(plpy) -> str:
    r = plpy.execute(
        "select pg_catalog.current_setting('ai.openai_api_key', true) as api_key"
    )
    if len(r) == 0:
        plpy.error("missing api key")
    return r[0]["api_key"]


def get_openai_base_url(plpy) -> Optional[str]:
    r = plpy.execute(
        "select pg_catalog.current_setting('ai.openai_base_url', true) as base_url"
    )
    if len(r) == 0:
        return None
    return r[0]["base_url"]


def make_client(
    plpy, api_key: Optional[str] = None, base_url: Optional[str] = None
) -> openai.Client:
    if api_key is None:
        api_key = get_openai_api_key(plpy)
    if base_url is None:
        base_url = get_openai_base_url(plpy)
    return openai.Client(api_key=api_key, base_url=base_url)


def process_json_input(input_value):
    """Process JSON input, returning None if input is NULL."""
    return json.loads(input_value) if input_value is not None else None
