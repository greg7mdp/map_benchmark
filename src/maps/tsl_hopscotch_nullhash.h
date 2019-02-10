#pragma once

#include "hashes.h"
#include "tsl/hopscotch_map.h"

static const char* MapName = "tsl::hopscotch_map hash::Null";

template <class Key, class Val>
using Map = tsl::hopscotch_map<Key, Val, hash::Null<Key>>;
