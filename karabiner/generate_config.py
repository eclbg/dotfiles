import json
import unittest
import functools

BASE_CONFIG = "base-config.json"
FULL_CONFIG = "full-config.json"


def spacefn(
    key_from: str,
    key_to: str,
    description: str | None = None,
    key_to_modifiers: list[str] | None = None,
) -> dict:
    manipulators = []
    to_dict = {"key_code": key_to}
    if key_to_modifiers:
        to_dict["modifiers"] = key_to_modifiers
    manipulator = {
        "from": {
            "modifiers": {"optional": ["any"]},
            "simultaneous": [{"key_code": "spacebar"}, {"key_code": key_from}],
            "simultaneous_options": {
                "key_down_order": "strict",
                "key_up_order": "strict_inverse",
                "to_after_key_up": [
                    {"set_variable": {"name": "SpaceFN", "value": 0}},
                ],
            },
        },
        "parameters": {"basic.simultaneous_threshold_milliseconds": 500},
        "to": [
            {"set_variable": {"name": "SpaceFN", "value": 1}},
            to_dict,
        ],
        "type": "basic",
    }
    if description:
        manipulator["description"] = description
    manipulators.append(manipulator)
    manipulator = {
        "conditions": [{"name": "SpaceFN", "type": "variable_if", "value": 1}],
        "from": {"key_code": key_from, "modifiers": {"optional": ["any"]}},
        "to": [to_dict],
        "type": "basic",
    }
    if description:
        manipulator["description"] = f"{description} from variable"
    manipulators.append(manipulator)
    return manipulators


def generate_additional_rules():
    rules_definition = [
        {
            "description": "space layer",
            "conditions": [
                {
                    "type": "device_if",
                    "identifiers": [{"product_id": 591, "vendor_id": 1452}],
                }
            ],
            "modifications": [
                functools.partial(
                    spacefn,
                    "f",
                    "9",
                    description="f = (",
                    key_to_modifiers=["left_shift"],
                ),
                functools.partial(
                    spacefn,
                    "j",
                    "0",
                    description="j = )",
                    key_to_modifiers=["left_shift"],
                ),
                functools.partial(
                    spacefn,
                    "d",
                    "open_bracket",
                    description="d = [",
                ),
                functools.partial(
                    spacefn,
                    "k",
                    "close_bracket",
                    description="k = ]",
                ),
                functools.partial(
                    spacefn,
                    "s",
                    "open_bracket",
                    description="s = {",
                    key_to_modifiers=["left_shift"],
                ),
                functools.partial(
                    spacefn,
                    "l",
                    "close_bracket",
                    description="l = }",
                    key_to_modifiers=["left_shift"],
                ),
                # This doesn't seem to be necessary. Holding space repeats the input
                # functools.partial(
                #     spacefn,
                #     "b",
                #     "spacebar",
                #     description="b to hold down space",
                # ),
            ],
        },
    ]
    expanded_rules = []
    for rule in rules_definition:
        expanded_rule = {
            "description": rule["description"],
        }
        if conditions := rule.get("conditions"):
            expanded_rule["conditions"] = conditions
        manipulators = expanded_rule.setdefault("manipulators", [])
        for modification in rule["modifications"]:
            manipulators.extend(modification())
        expanded_rules.append(expanded_rule)
    return expanded_rules


def extend_base_config(base_config, additional_rules):
    eclbg_profile = next(
        filter(lambda x: x["name"] == "eclbg", base_config["profiles"])
    )
    rules = eclbg_profile["complex_modifications"]["rules"]
    _ = rules.extend(additional_rules)
    return base_config


def generate_config():
    base_config = json.load(open(BASE_CONFIG))
    additional_rules = generate_additional_rules()
    full_config = extend_base_config(base_config, additional_rules)
    json.dump(full_config, open(FULL_CONFIG, "w"), indent=4)


if __name__ == "__main__":
    generate_config()


class ConfigGeneratorTestCase(unittest.TestCase):
    def test_spacefn(self):
        expected = [
            {
                "description": "f = (",
                "from": {
                    "modifiers": {"optional": ["any"]},
                    "simultaneous": [{"key_code": "spacebar"}, {"key_code": "f"}],
                    "simultaneous_options": {
                        "key_down_order": "strict",
                        "key_up_order": "strict_inverse",
                        "to_after_key_up": [
                            {"set_variable": {"name": "SpaceFN", "value": 0}}
                        ],
                    },
                },
                "parameters": {"basic.simultaneous_threshold_milliseconds": 500},
                "to": [
                    {"set_variable": {"name": "SpaceFN", "value": 1}},
                    {"key_code": "9", "modifiers": ["left_shift"]},
                ],
                "type": "basic",
            },
            {
                "description": "f = ( from variable",
                "conditions": [{"name": "SpaceFN", "type": "variable_if", "value": 1}],
                "from": {"key_code": "f", "modifiers": {"optional": ["any"]}},
                "to": [{"key_code": "9", "modifiers": ["left_shift"]}],
                "type": "basic",
            },
        ]
        result = functools.partial(
            spacefn,
            "f",
            "9",
            description="f = (",
            key_to_modifiers=["left_shift"],
        )
        self.assertEqual(expected, result())
