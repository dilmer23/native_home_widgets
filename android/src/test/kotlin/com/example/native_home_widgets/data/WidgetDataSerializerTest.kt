package com.example.native_home_widgets.data

import org.junit.Test
import org.junit.Assert.*

class WidgetDataSerializerTest {

    @Test
    fun serialize_string_returnsSame() {
        assertEquals("hello", WidgetDataSerializer.serialize("hello"))
    }

    @Test
    fun serialize_int_returnsString() {
        assertEquals("42", WidgetDataSerializer.serialize(42))
    }

    @Test
    fun serialize_boolean_returnsString() {
        assertEquals("true", WidgetDataSerializer.serialize(true))
    }

    @Test
    fun serialize_null_returnsNullString() {
        assertEquals("null", WidgetDataSerializer.serialize(null))
    }

    @Test
    fun deserialize_string_returnsString() {
        assertEquals("hello", WidgetDataSerializer.deserialize("hello"))
    }

    @Test
    fun deserialize_int_returnsInt() {
        assertEquals(42, WidgetDataSerializer.deserialize("42"))
    }

    @Test
    fun deserialize_booleanTrue_returnsTrue() {
        assertEquals(true, WidgetDataSerializer.deserialize("true"))
    }

    @Test
    fun deserialize_booleanFalse_returnsFalse() {
        assertEquals(false, WidgetDataSerializer.deserialize("false"))
    }

    @Test
    fun deserialize_null_returnsNull() {
        assertNull(WidgetDataSerializer.deserialize("null"))
    }

    @Test
    fun roundTrip_int_preservesValue() {
        val original = 123
        val serialized = WidgetDataSerializer.serialize(original)
        assertEquals(original, WidgetDataSerializer.deserialize(serialized))
    }

    @Test
    fun roundTrip_string_preservesValue() {
        val original = "test value"
        val serialized = WidgetDataSerializer.serialize(original)
        assertEquals(original, WidgetDataSerializer.deserialize(serialized))
    }
}
