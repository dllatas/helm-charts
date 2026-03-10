# Changelog

## 0.0.4

- Added `defaults` support for shared namespace, labels, annotations, token behavior, image pull secrets, and referenced secrets.

## 0.0.3

- Added optional `secrets[]` support so service accounts can reference named secrets directly.

## 0.0.2

- Added `global` schema support so the chart can be consumed cleanly as a dependency.

## 0.0.1

- Initial public release of the `service-account` chart.
- Added support for rendering multiple service accounts across namespaces.
- Added strict schema validation and duplicate-name guards.
