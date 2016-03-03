#### COMPILER DIRECTIVES

On schemes `LetGoDEV` and `LetGoPROD` there's a `GOD_MODE` compiler directive. We're using that directive to enable a new field on system settings to choose api environment. Those are the following selectable environments:

- **Production**:   Production api + production keys
- **Canary**: Canary api + production keys
- **Staging**: Staging api + development keys

*The usage of `GOD_MODE`can be checked on `EnvironmentsHelper.swift` class*


#### Do not use those schemes to publish to appstore!