# Godot Animated Box Container Plugin GDScrpit Ver

![Godot v4.x](https://img.shields.io/badge/Godot-v4.x-%23478cbf?logo=godot-engine&logoColor=white&style=flat-square)

This plugin will animate layout direction change in container.

C# version is at [GramineaGroup/animated_box_container_cs](https://github.com/GramineaGroup/animated_box_container_cs)

Please submit any issues you found. Contribution and suggestions are warmly welcomed.

## Setting Recommendation

It is recommended not to use `Fill` size flag for both vertical and horizontal direction for children under `Animated Box Container`. Using it will have incorrect animation set for all children, causing unexpected behaviors.

Using `Animated Box Container` together with [Animated Panel Container](https://github.com/GramineaGroup/animated_panel_container_gdscript) is recommended as we have special variable in `Animated Panel Container` for `Animated Box Container` to know the final size of any `Animated Panel Container` children.

## Demo

### Changing Layout Direction Like a Normal Box Container


https://github.com/user-attachments/assets/758679e8-0e9c-4938-93ee-80c9e7f03c60


### Changing Layout Direction but with Animation


https://github.com/user-attachments/assets/2d81051a-25b7-47bc-9917-9d15b12ac2b0


### Integrated with `Animated Panel Container` to Get Scaling Animation


https://github.com/user-attachments/assets/1e1cd473-3545-4337-bb0f-10a5ec054db9

