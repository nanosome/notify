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

package nanosome.notify.bind.impl {
	import nanosome.notify.field.IField;
	import nanosome.util.IUID;
	import nanosome.util.list.UIDListNode;
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class FieldBindListNode extends UIDListNode {
		
		// TODO: NOTE weak entries are by now not used!
		
		public var field: IField;
		public var nextNode: FieldBindListNode;
		
		public function FieldBindListNode() {
			super();
		}
		
		override public function set strong( content: IUID ): void {
			field = IField( content );
		}
		
		override public function get strong(): IUID {
			return field;
		}

		override public function set next(node : UIDListNode) : void {
			super.next = node;
			nextNode = FieldBindListNode( node );
		}
	}
}
