#!/usr/bin/env bash
set -e

CI=true npm test -- --watchAll=false
