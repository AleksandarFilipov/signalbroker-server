/*
 * Copyright 2019 Volvo Cars
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * ”License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * “AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#include <csunixds.h>
#include <stdio.h>
#include <assert.h>

int main(int argc, char *argv[]) {

	fprintf(stderr, "Core System Unix Domain Socket sample.\n"
			"Library version: \"%s\".\n",
			CS_VERSION_STR);

	// Connect
	//=========================================================================
	assert(cs_initialize(NULL) == CS_OK);

	// Write some signals
	//=========================================================================
	/*
	 * 3 signals:
	 * A = 1.0
	 * B = 2.0
	 * C = 3.0
	 */
	const char *names[] = { "A", "B", "C" };
	const cs_value_t write_values[] = {
		{CS_TYPE_F64, .value_f64=1.0},
		{CS_TYPE_F64, .value_f64=2.0},
		{CS_TYPE_F64, .value_f64=3.0}};

	for (int u=0; u<5; u++) {
		assert(cs_write(3, names, write_values) == CS_OK);
	}

	// Read som signals
	//=========================================================================
	/*
	 * 3 signals:
	 * A
	 * B
	 * C
	 */
	cs_value_t read_values[3];
	for (int u=0; u<4; u++) {
		assert(cs_read(3, names, read_values) == CS_OK);

		for (int i=0; i<3; i++) {
			fprintf(stderr, "[%s] = [%f]\n", names[i], read_values[i].value_f64);
		}
	}

	// Subscribe to event
	//=========================================================================
	assert(cs_subscribe(3, names) == CS_OK);

	int count = 4;

	cs_wait_mode_t event(
			int signal_count, const char *const names[],
			const cs_value_t values[]) {

		fprintf(stderr, "Got event with %d signals!\n", signal_count);

		for (int i=0; i<signal_count; i++) {
			fprintf(stderr,
					"[%s] = [%f]\n",
					names[i],
					values[i].value_f64);
		}

		count--;

		if (count > 0) {
			fprintf(stderr, "Continue block!\n");
			return CS_BLOCK_CONTINUE;
		} else {
			fprintf(stderr, "Stop block!\n");
			return CS_BLOCK_STOP;
		}
	}

	cs_event_loop(event);


	// Shut down connection
	//=========================================================================
	assert(cs_shutdown() == CS_OK);

	return 0;
}

