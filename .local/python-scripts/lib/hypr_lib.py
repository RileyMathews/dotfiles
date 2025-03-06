from dataclasses import dataclass
from dataclasses_json import dataclass_json, Undefined


@dataclass_json(undefined=Undefined.EXCLUDE)
@dataclass
class HyprlandMonitorsResponse:
    id: int
    name: str
