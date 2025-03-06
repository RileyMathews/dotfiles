from dataclasses import dataclass
from dataclasses_json import DataClassJsonMixin, dataclass_json, Undefined


@dataclass_json(undefined=Undefined.EXCLUDE)
@dataclass
class HyprlandMonitorsResponse(DataClassJsonMixin):
    id: int
    name: str
    x: int
    y: int
    width: int
    height: int
    scale: float

    def keyword_restore_command(self) -> str:
        return f"keyword monitor {self.name},{self.width}x{self.height},{self.x}x{self.y},{self.scale}"

    def disable_command(self) -> str:
        return f"keyword monitor {self.name},disable"
