# Aturan R8 tambahan untuk build release.

# WorkManager (dibawa play-services-ads) dibuka androidx.startup saat aplikasi
# mulai dan membuat WorkDatabase_Impl lewat refleksi (newInstance). Aturan
# room-runtime 2.2.5 hanya menyimpan kelasnya; R8 full mode membuang
# konstruktornya, jadi aplikasi crash sebelum Flutter jalan ("Failed to create
# an instance of androidx.work.impl.WorkDatabase").
-keep class * extends androidx.room.RoomDatabase { <init>(); }
