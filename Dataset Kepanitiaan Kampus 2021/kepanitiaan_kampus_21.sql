use kepanitiaan_kampus_21;

#PENENTUAN RANKING JURUSAN DENGAN KONTRIBUSI TERBESAR BAGI KEPANITIAAN BEM
select
	dense_rank () over(order by sum(bobot_jabatan * bobot_nilai)/jumlah_mhs desc) as ranking,
    jurusan_id,
    nama_jurusan,
    nama_fakultas,
    jumlah_mhs,
    floor(sum(bobot_jabatan * bobot_nilai)/jumlah_mhs) as nilai_akhir,
    case
		when dense_rank () over(order by sum(bobot_jabatan * bobot_nilai)/jumlah_mhs desc) < 4 
			then "Mendapatkan Apresiasi dari BEM Kampus"
		when dense_rank () over(order by sum(bobot_jabatan * bobot_nilai)/jumlah_mhs desc) < 19
			then "Perlu Dijaga untuk Tetap Berkegiatan di BEM"
		else "Perlu Persuasif Lebih Banyak di Tahun Depan"
    end as status
from data_panitia dp
	left join data_jurusan dj
		on floor(mhs_id/100000) = jurusan_id
	left join data_jabatan
		on mod(floor(panitia_id/10000),1000) = jabatan_id
	left join data_nilai
		using (nilai)
group by nama_jurusan
order by nilai_akhir desc;

#PENENTUAN MAHASISWA DENGAN TOTAL KEPANITIAAN TERBANYAK DI TIAP JURUSAN
select
	dense_rank () over(order by mhs_id) as no,
	mhs_id, 
    nama_mhs, 
    nama_jurusan, 
    nama_fakultas, 
    concat("Telah mengikuti ", jumlah_kepanitiaan, " Kepanitiaan BEM Selama Tahun 2022") as catatan
from (	select
			*,
			count(jabatan) as jumlah_kepanitiaan,
			sum(bobot_nilai * bobot_jabatan) as nilai_total
		from data_panitia
			left join data_mhs
				using (mhs_id)
			left join data_nilai
				using (nilai)
			left join data_jurusan
				on floor(mhs_id/100000) = jurusan_id
			left join data_jabatan
				on mod(floor(panitia_id/10000),1000) = jabatan_id
		group by mhs_id
		order by jurusan_id, jumlah_kepanitiaan desc, nilai_total) summary
group by nama_jurusan;