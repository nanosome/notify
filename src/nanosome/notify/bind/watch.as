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
	import nanosome.notify.bind.impl.PropertyRoot;
	import nanosome.notify.bind.impl.WatchField;
	
	/**
	 * <code>watch</code> listens to property changes of annonymous classes and provides
	 * a standard manner to listen to those changes.
	 * 
	 * <p><code>watch</code> offers a complex mechanism that allows to listen to
	 * changes with the structure of a annonymous object. It chooses depending on the
	 * type of the property whether it can be listened-to with the nanosome-observe
	 * mechanism. Or if updates are sent out via flex binding. If the object does
	 * not support one of those two update mechanisms it will check it on a less-performant
	 * EnterFrame basis.</p>
	 * 
	 * <p>Internal and/or dymanic classes can not be properly analysed by this method,
	 * this means that it will use the EnterFrame mechanism for every property whic
	 * can lead to <strong>very</strong> weak performance.</p>
	 * 
	 * @param object Root object to watch.
	 * @param path Path in the root object of the property
	 * @return a field that will publish changes if that certain property changes
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see nanosome.notify.impl.WatchField
	 * @see nanosome.notify.field.IWatchField
	 * @see nanosome.notify.bind#bind()
	 * @see nanosome.notify.bind#unbind()
	 * @see nanosome.util.EnterFrame
	 */
	public function watch( object: *, path: String ): IWatchField {
		if( !path ) {
			path = "";
		}
		
		var pathList: Array = path.split( "." );
		var propertyName: String = pathList.shift();
		
		var propertyMO: WatchField = PropertyRoot.forObject( object ).property( propertyName );
		while( propertyName = pathList.shift() ) {
			propertyMO = propertyMO.property( propertyName );
		}
		
		return propertyMO;
	}
}
