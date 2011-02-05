//  
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License. 
// 
package nanosome.notify.bind {
	import nanosome.notify.field.IField;
	import nanosome.notify.bind.impl.BINDER;
	
	/**
	 * Interconnects two <code>IField</code> instances to update on changes.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @param fieldA First field to be bound
	 *             (the value of this <code>IField</code> will be automatically given to second one)
	 * @param fieldB Second field to be bound
	 * @return fieldA
	 * @see nanosome.notify.bind#bind()
	 * @see nanosome.notify.bind#unbindMO()
	 * @see nanosome.notify.bind#unbind()
	 */
	public function bindFields( fieldA: IField, fieldB: IField, bidirectional: Boolean = true ): IField {
		return BINDER.bind( fieldA, fieldB, bidirectional );
	}
}
