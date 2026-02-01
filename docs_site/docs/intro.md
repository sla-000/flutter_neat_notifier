---
sidebar_position: 1
---

# Introduction

**neat_state** is a lightweight, feature-rich state management package for Flutter that builds upon `ValueNotifier` to provide a robust solution for handling states, one-time actions, and asynchronous operations with built-in loading and error management.

## Why neat_state?

- **Zero Boilerplate**: No need to create separate classes for events or state if you don't want to.
- **Familiar API**: If you know `ValueNotifier`, you know `neat_state`.
- **Built-in Async**: Native support for loading states and error handling.
- **One-time Actions**: Perfect for snackbars, navigation, or dialogs.
- **Granular Rebuilds**: Optimized with `InheritedModel` and `context.select`.

## Live Demo

Here is a simple counter example working live.

<iframe
  src="https://dartpad.dev/embed-flutter.html?id=c7e3f8b0e7d5d7e8b6e3f8b0e7d5d7e8"
  style={{width: '100%', height: '500px', border: 'none'}}
></iframe>

:::note
The Gist ID above is a placeholder. In the actual implementation, we will use real Gists containing the library code and example.
:::

## Next Steps

- [Installation](./intro.md#installation)
- [Simple Example](./intro.md#simple-example)
- [Hydrated Notifiers](./intro.md#hydrated-state)
