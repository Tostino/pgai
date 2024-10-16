import json
import asyncio
import openai
from typing import Optional, Any, Dict, Callable, Awaitable


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


def make_async_client(
        plpy, api_key: Optional[str] = None, base_url: Optional[str] = None, timeout: Optional[float] = None
) -> openai.AsyncOpenAI:
    if api_key is None:
        api_key = get_openai_api_key(plpy)
    if base_url is None:
        base_url = get_openai_base_url(plpy)

    client_kwargs = prepare_kwargs({
        "api_key": api_key,
        "base_url": base_url,
        "timeout": timeout
    })

    return openai.AsyncOpenAI(**client_kwargs)


def process_json_input(input_value):
    """Process JSON input, returning None if input is NULL."""
    return json.loads(input_value) if input_value is not None else None

def is_query_cancelled(plpy):
    try:
        plpy.execute("SELECT 1")
        return False
    except plpy.SPIError:
        return True


def execute_with_cancellation(plpy, client: openai.AsyncOpenAI, async_func: Callable[[openai.AsyncOpenAI, Dict[str, Any]], Awaitable[Dict[str, Any]]], **kwargs) -> Dict[str, Any]:
    async def main():
        task = asyncio.create_task(async_func(client, kwargs))
        while not task.done():
            if is_query_cancelled(plpy):
                task.cancel()
                raise plpy.SPIError("Query cancelled by user")
            await asyncio.sleep(0.1)  # 100ms
        return await task

    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(main())
    return result


def prepare_kwargs(params: Dict[str, Any]) -> Dict[str, Any]:
    return {k: v for k, v in params.items() if v is not None}
