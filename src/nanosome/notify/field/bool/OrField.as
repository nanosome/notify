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

package nanosome.notify.field.bool {
	import nanosome.notify.field.IBoolField;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	internal class OrField extends AndField {
		public function OrField( mos: Array ) {
			super( mos );
		}
		
		override protected function getValue(): Boolean {
			for( var i:int=0; i<_l; ++i ) {
				if( IBoolField( _fields[i] ).isTrue ) {
					return true;
				}
			}
			return false;
		}
	}
}
