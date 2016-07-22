/*
 *  Copyright 2016 Frank Hunleth
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef UTIL_H
#define UTIL_H

#ifdef DEBUG
FILE *log_location;
#define LOG_LOCATION log_location
#define debug(...) do { fprintf(stderr, __VA_ARGS__); fprintf(stderr, "\r\n"); fflush(stderr); } while(0)
#else
#define LOG_LOCATION stderr
#define debug(...)
#endif

#endif // UTIL_H
