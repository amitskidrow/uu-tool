#!/usr/bin/env bash

parse_args() {
  # Handle help first before requiring target
  while (( $# )); do
    case "$1" in
      -h|--help) usage; exit 0 ;;
      *) break ;;
    esac
  done
  
  (( $# >= 1 )) || { usage; exit 2; }
  TARGET_INPUT="$1"; shift || true
  while (( $# )); do
    case "$1" in
      --service) SERVICE="$2"; shift 2 ;;
      --entry) ENTRY="$2"; shift 2 ;;
      --makefile-out) MAKEFILE_OUT="$2"; shift 2 ;;
      --readme-out) README_OUT="$2"; shift 2 ;;
      --mk-only) MK_ONLY=1; shift ;;
      --readme-only) README_ONLY=1; shift ;;
      --dry-run) DRY_RUN=1; shift ;;
      --yes) YES=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    esac
  done
  if (( MK_ONLY && README_ONLY )); then warn "--mk-only and --readme-only both set; will generate both."; fi
}

